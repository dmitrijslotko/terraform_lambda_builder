resource "local_file" "create_sam_template" {
  count = var.deploy_mode == "SAM" ? 1 : 0
  content = yamlencode(
    {
      AWSTemplateFormatVersion : "2010-09-09",
      Transform : "AWS::Serverless-2016-10-31",
      Resources : {
        replace("${var.function_name}", "/[^A-Za-z\\d]/", "") : {
          Type : "AWS::Serverless::Function",
          Properties : merge({
            Handler : var.lambda_handler,
            Runtime : var.lambda_runtime,
            MemorySize : var.lambda_memory,
            Timeout : var.lambda_timeout,
            FunctionName : var.function_name,
            Role : var.lambda_role_arn == null ? aws_iam_role.lambda_builder_iam_role[count.index].arn : var.lambda_role_arn,
            AutoPublishAlias : var.alias,
            DeploymentPreference : {
              Enabled : var.gradual_deployment,
              Type : var.gradual_deployment_type,
              Alarms : [aws_cloudwatch_metric_alarm.lambda_deploy_alarm[0].arn]
            }
            },
            var.layers == null ? {} : { Layer : var.layers },
            var.subnet_ids == null ? {} : { VpcConfig : {
              SecurityGroupIds : var.security_group_ids,
              SubnetIds : var.subnet_ids
              }
            },
            var.enviroment_variables == null ? {} : {
              Environment : {
                Variables : merge(var.enviroment_variables, var.layers != null ? {
                  layer_prefix = local.layer_prefix
                  } : null, var.add_efs != true ? {
                  local_mount_path = local.local_mount_path
                } : null)
              }
            }
          )
        }
      }
    }
  )
  filename = "${var.file_name}/template.yaml"
}

data "archive_file" "sam_archive" {
  count       = var.deploy_mode == "SAM" ? 1 : 0
  type        = "zip"
  source_dir  = var.file_name
  output_path = "${path.module}/.build/${var.function_name}.zip"

  depends_on = [
    local_file.create_sam_template[0]
  ]
}

resource "aws_s3_bucket_object" "sam_artifact" {
  count  = var.deploy_mode == "SAM" ? 1 : 0
  bucket = var.artifact_bucket
  key    = "${var.artifact_key}.zip"
  source = data.archive_file.sam_archive[count.index].output_path
  etag   = data.archive_file.sam_archive[count.index].output_md5
}

resource "aws_codebuild_project" "sam_project" {
  count         = var.deploy_mode == "SAM" ? 1 : 0
  name          = var.function_name
  description   = "automated SAM build"
  build_timeout = var.build_timeout
  service_role  = aws_iam_role.service_role[count.index].arn

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  source {
    type      = "S3"
    location  = "${aws_s3_bucket_object.sam_artifact[count.index].bucket}/${aws_s3_bucket_object.sam_artifact[count.index].key}"
    buildspec = file("${path.module}/sam_buildspec.yml")
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  depends_on = [
    aws_iam_role.service_role[0]
  ]
}


resource "null_resource" "sam_codebuild_start" {
  count = var.deploy_mode == "SAM" ? 1 : 0
  triggers = {
    etag = data.archive_file.sam_archive[count.index].output_md5
  }

  provisioner "local-exec" {
    working_dir = path.module
    command     = "npm i"
  }

  provisioner "local-exec" {
    working_dir = path.module
    command     = "node codebuild_launch.js ${var.function_name} ${local.region} false"
    on_failure  = fail
  }

  depends_on = [
    aws_codebuild_project.sam_project[0]
  ]
}
