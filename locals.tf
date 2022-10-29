locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  # tags             = data.aws_default_tags.tags["APPLICATION"]
  local_mount_path   = "/mnt/efs"
  layer_prefix       = "/opt/nodejs/"
  function_name      = var.alias != null ? aws_lambda_alias.lambda_alias[0].arn : aws_lambda_function.lambda.arn
  arn                = var.alias != null ? aws_lambda_alias.lambda_alias[0].arn : aws_lambda_function.lambda.arn
  cw_rule            = var.cw_event_input != null && var.cw_event_cron_expression != null
  external_role_name = var.role_arn != "" ? split("/", var.role_arn)[1] : ""
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_default_tags" "tags" {}
