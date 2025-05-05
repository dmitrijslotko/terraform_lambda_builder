resource "aws_lambda_function" "lambda" {
  filename          = var.s3_source_config == null && var.docker_config == null ? data.archive_file.archive[0].output_path : null
  function_name     = var.config.function_name
  role              = var.config.role_arn == null ? aws_iam_role.lambda_builder_iam_role[0].arn : var.config.role_arn
  handler           = var.docker_config != null ? null : var.config.handler
  description       = var.config.description
  source_code_hash  = try(var.config.force_deploy == true ? null : var.docker_config != null ? filesha1(var.docker_config.dockerfile_path) : data.archive_file.archive[0].output_base64sha256, null)
  runtime           = var.docker_config != null ? null : var.config.runtime
  timeout           = var.config.timeout
  layers            = var.config.layers
  package_type      = var.docker_config != null ? "Image" : "Zip"
  memory_size       = var.config.memory_size
  image_uri         = var.docker_config != null ? var.docker_config.repository_url == null ? "${aws_ecr_repository.repo[0].repository_url}:latest" : var.docker_config.repository_url : null
  publish           = var.config.publish || var.alias_config != null
  s3_bucket         = var.s3_source_config != null ? var.s3_source_config.bucket : null
  s3_key            = var.s3_source_config != null ? var.s3_source_config.key : null
  s3_object_version = var.s3_source_config != null ? var.s3_source_config.object_version : null
  architectures     = var.docker_config != null ? [var.docker_config.platform] : [var.config.architecture]
  kms_key_arn       = var.config.lambda_kms_key_arn
  tags              = var.config.tags
  ephemeral_storage {
    size = var.config.ephemeral_storage
  }

  dynamic "environment" {
    for_each = var.config.environment_variables != null || var.config.layers != null || var.efs_config != null ? ["a sigle element to trigger the block"] : []
    content {
      variables = merge(var.config.environment_variables, var.efs_config != null ? { LOCAL_MOUNT_PATH : var.efs_config.mount_path } : {}, var.config.layers != null ? { LAYER_PREFIX : local.layer_prefix } : {})
    }
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config == null ? [] : ["a sigle element to trigger the block"]
    content {
      subnet_ids         = var.vpc_config.subnet_ids
      security_group_ids = var.vpc_config.security_group_ids
    }
  }

  dynamic "file_system_config" {
    for_each = var.efs_config == null ? [] : ["a sigle element to trigger the block"]
    content {
      # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
      # Local mount path inside the lambda function. Must start with '/mnt/'.
      arn              = aws_efs_access_point.access_point_for_lambda[0].arn
      local_mount_path = var.efs_config.mount_path
    }
  }

  dynamic "image_config" {
    for_each = var.docker_config == null ? [] : ["a sigle element to trigger the block"]
    content {
      command = [var.config.handler]
    }
  }

  depends_on = [
    aws_ecr_repository.repo,
    null_resource.deploy_docker_image,
  ]
}

resource "aws_cloudwatch_log_group" "log" {
  count             = var.log_group_config == null ? 0 : 1
  name              = "/aws/lambda/${var.config.function_name}"
  retention_in_days = var.log_group_config.retention_in_days
  tags              = var.config.tags
  kms_key_id        = var.config.cloudwatch_kms_key_arn
}

resource "null_resource" "deploy_docker_image" {
  count = try(var.docker_config.create_repository, false) ? 1 : 0

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    working_dir = path.module
    command     = "bash deploy.sh ${aws_ecr_repository.repo[0].repository_url} ${var.config.function_name} ${abspath(path.root)}/${var.docker_config.dockerfile_path} ${var.docker_config.os}/${var.docker_config.platform}"
  }

  depends_on = [
    aws_ecr_repository.repo
  ]
}
