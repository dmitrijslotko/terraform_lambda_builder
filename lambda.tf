resource "aws_lambda_function" "lambda" {
  filename          = var.s3_source_config == null ? data.archive_file.archive.output_path : null
  function_name     = var.config.function_name
  role              = var.config.role_arn == null ? aws_iam_role.lambda_builder_iam_role[0].arn : var.config.role_arn
  handler           = var.config.handler
  description       = var.config.description
  source_code_hash  = try(var.config.force_deploy == true ? null : data.archive_file.archive.output_base64sha256, null)
  runtime           = var.config.runtime
  timeout           = var.config.timeout
  layers            = var.config.layers
  memory_size       = var.config.memory_size
  publish           = var.config.publish || var.alias_config != null
  s3_bucket         = try(var.s3_source_config.bucket, null)
  s3_key            = try(var.s3_source_config.key, null)
  s3_object_version = try(var.s3_source_config.object_version, null)
  architectures     = [var.config.architecture]
  ephemeral_storage {
    size = var.config.ephemeral_storage
  }

  dynamic "environment" {
    for_each = var.config.environment_variables != null || var.config.layers != null || var.efs_config != null ? ["a sigle element to trigger the block"] : []
    content {
      variables = merge(var.config.environment_variables, var.efs_config != null ? { local_mount_path : var.efs_config.mount_path } : {}, var.config.layers != null ? { layer_prefix : var.config.layer_prefix } : {})
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
}

resource "aws_cloudwatch_log_group" "log" {
  count             = var.log_group_config == null ? 0 : 1
  name              = "/aws/lambda/${var.config.function_name}"
  retention_in_days = var.log_group_config.retention_in_days
}
