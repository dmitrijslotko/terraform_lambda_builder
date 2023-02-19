resource "aws_lambda_alias" "lambda_alias" {
  count            = var.alias_config != null ? 1 : 0
  name             = var.alias_config.name
  function_name    = aws_lambda_function.lambda.arn
  function_version = aws_lambda_function.lambda.version
  description      = var.alias_config.description

  dynamic "routing_config" {
    for_each = var.alias_config.stable_version != null && var.alias_config.stable_version_weights < 1 && aws_lambda_function.lambda.version > 1 ? ["a sigle element to trigger the block"] : []
    content {
      additional_version_weights = {
        var.alias_config.stable_version == null ? aws_lambda_function.lambda.version : var.alias_config.stable_version = var.alias_config.stable_version_weights
      }
    }
  }
}

resource "null_resource" "clean_old_versions" {
  count = var.alias_config != null ? 1 : 0
  triggers = {
    etag = data.archive_file.archive.output_base64sha256
  }

  provisioner "local-exec" {
    working_dir = path.module
    command     = "npm i"
  }

  provisioner "local-exec" {
    working_dir = path.module
    command     = "node clean_old_lambda_versions.js ${var.config.function_name} ${var.alias_config.versions_to_keep} ${local.region}"
  }

  depends_on = [
    aws_lambda_alias.lambda_alias
  ]
}
