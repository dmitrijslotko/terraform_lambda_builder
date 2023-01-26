locals {
  account_id       = data.aws_caller_identity.current.account_id
  region           = data.aws_region.current.name
  local_mount_path = "/mnt/efs"
  layer_prefix     = "/opt/nodejs/"
  function_name    = var.alias != null ? aws_lambda_alias.lambda_alias[0].arn : aws_lambda_function.lambda.arn
  arn              = var.alias != null ? aws_lambda_alias.lambda_alias[0].arn : aws_lambda_function.lambda.arn
  cw_rule          = var.cw_event_input != null && var.cw_event_cron_expression != null
  s3_source        = var.bucket != null && var.key != null
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_default_tags" "tags" {}
