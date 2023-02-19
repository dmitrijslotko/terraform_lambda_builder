locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  # tags             = data.aws_default_tags.tags["APPLICATION"]
  layer_prefix  = "/opt/nodejs/"
  function_name = var.alias_config != null ? aws_lambda_alias.lambda_alias[0].arn : aws_lambda_function.lambda.arn
  arn           = var.alias_config != null ? aws_lambda_alias.lambda_alias[0].arn : aws_lambda_function.lambda.arn
  filename      = var.s3_source_config == null ? data.archive_file.archive.output_path : "s3://${var.s3_source_config.bucket}/${var.s3_source_config.key}"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_default_tags" "tags" {}
