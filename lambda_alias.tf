resource "aws_lambda_alias" "lambda_alias" {
  count            = var.alias_config != null ? 1 : 0
  name             = var.alias_config.name
  function_name    = aws_lambda_function.lambda.arn
  function_version = aws_lambda_function.lambda.version
  description      = var.alias_config.description

  routing_config {
    additional_version_weights = try({ "${var.alias_config.stable_version}" = var.alias_config.stable_version_weights }, null)
  }
}
resource "null_resource" "clean_old_versions" {
  count = try(var.alias_config == null || var.alias_config.versions_to_keep == null ? 0 : 1, 0)
  triggers = {
    etag = try(var.alias_config.force_delete_old_versions == true ? timestamp() : data.archive_file.archive[0].output_base64sha256, data.archive_file.archive[0].output_base64sha256)
  }

  provisioner "local-exec" {
    working_dir = path.module
    command     = "python node clean_old_lambda_versions.js  ${var.config.function_name} ${var.alias_config.versions_to_keep}"
  }

  depends_on = [
    aws_lambda_alias.lambda_alias
  ]
}

