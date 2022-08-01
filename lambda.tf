resource "aws_lambda_function" "lambda" {
  filename         = data.archive_file.archive.output_path
  function_name    = var.function_name
  role             = var.role_arn == "" ? aws_iam_role.lambda_builder_iam_role.arn : var.role_arn
  handler          = var.handler
  source_code_hash = data.archive_file.archive.output_base64sha256
  runtime          = var.runtime
  timeout          = var.timeout
  layers           = var.layers
  memory_size      = var.memory_size
  publish          = var.alias != null
  ephemeral_storage {
    size = var.ephemeral_storage
  }

  dynamic "environment" {
    for_each = var.environment_variables != null || var.layers != null || var.add_efs ? ["a sigle element to trigger the block"] : []
    content {
      variables = merge(var.environment_variables, var.add_efs ? { local_mount_path : local.local_mount_path } : {}, var.layers != null ? { layer_prefix : local.layer_prefix } : {})
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
    for_each = var.add_efs ? [var.add_efs] : []
    content {
      # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
      # Local mount path inside the lambda function. Must start with '/mnt/'.
      arn              = aws_efs_access_point.access_point_for_lambda[0].arn
      local_mount_path = local.local_mount_path
    }
  }
}

resource "aws_cloudwatch_log_group" "log" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.lambda_retention_in_days
}


data "archive_file" "archive" {
  type        = "zip"
  source_dir  = var.filename
  output_path = "${path.module}/.build/${var.function_name}.zip"
}


