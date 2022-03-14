resource "aws_lambda_alias" "lambda_alias" {
  count            = var.alias != null ? 1 : 0
  name             = var.alias
  function_name    = aws_lambda_function.lambda.arn
  function_version = aws_lambda_function.lambda.version

  dynamic "routing_config" {
    for_each = var.stable_version != null && var.stable_version_weights < 1 && aws_lambda_function.lambda.version > 1 ? ["a sigle element to trigger the block"] : []
    content {
      additional_version_weights = {
        var.stable_version == null ? aws_lambda_function.lambda.version : var.stable_version = var.stable_version_weights
      }
    }
  }
}

resource "null_resource" "clean_old_versions" {
  count = var.alias != null && var.versions_to_keep != null ? 1 : 0
  triggers = {
    etag = data.archive_file.archive.output_base64sha256
  }

  provisioner "local-exec" {
    working_dir = path.module
    command     = "npm i"
  }

  provisioner "local-exec" {
    working_dir = path.module
    command     = "node clean_old_lambda_versions.js ${var.function_name} ${var.versions_to_keep} ${local.region}"
  }

  depends_on = [
    aws_lambda_alias.lambda_alias
  ]
}
