resource "aws_lambda_function" "lambda" {
  filename                       = var.is_docker_lambda ? null : data.archive_file.archive.output_path
  image_uri                      = var.is_docker_lambda ? "${aws_ecr_repository.ecr[0].repository_url}:${data.aws_ecr_image.image[0].image_tags[1]}" : null
  function_name                  = var.function_name
  source_code_hash               = data.archive_file.archive.output_base64sha256
  role                           = aws_iam_role.lambda_builder_iam_role.arn
  handler                        = var.is_docker_lambda ? null : var.lambda_handler
  timeout                        = var.lambda_timeout
  runtime                        = var.is_docker_lambda ? null : var.lambda_runtime
  memory_size                    = var.lambda_memory
  package_type                   = var.is_docker_lambda ? "Image" : "Zip"
  layers                         = var.is_docker_lambda ? null : var.layers
  reserved_concurrent_executions = var.reserved_concurrent_executions
  dynamic "environment" {
    for_each = var.enviroment_variables != null || var.layers != null || var.add_efs != null || var.efs_access_point != null ? ["a sigle element to trigger the block"] : []
    content {
      variables = merge(var.enviroment_variables, var.layers != null ? {
        layer_prefix = local.layer_prefix
        } : null, var.add_efs != null || var.efs_access_point != null ? {
        local_mount_path = local.local_mount_path
      } : null)
    }
  }

  dynamic "vpc_config" {
    for_each = var.subnet_ids == null ? [] : ["a sigle element to trigger the block"]
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  dynamic "file_system_config" {
    for_each = var.add_efs == false ? var.efs_access_point == null ? [] : [var.efs_access_point] : [var.add_efs]
    content {
      # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
      # Local mount path inside the lambda function. Must start with '/mnt/'.
      arn              = var.add_efs == false ? var.efs_access_point : aws_efs_access_point.access_point_for_lambda[0].arn
      local_mount_path = var.add_efs == false ? var.local_mount_path : local.local_mount_path
    }
  }
}

resource "aws_cloudwatch_log_group" "log" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.cloudwatch_log_retention_in_days
}

data "archive_file" "archive" {
  type        = "zip"
  source_dir  = var.file_name
  output_path = "${path.module}/.build/${var.function_name}.zip"

  depends_on = [
    local_file.copy_default_buildspec
  ]
}

resource "aws_s3_bucket_object" "docker_artifact" {
  count  = local.docker_lambda_count
  bucket = var.artifact_bucket
  key    = "${var.artifact_path}/${local.docker_artifact}"
  source = data.archive_file.archive.output_path
  etag   = filemd5(data.archive_file.archive.output_path)
}
