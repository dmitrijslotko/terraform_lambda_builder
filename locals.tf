locals {
  account_id       = data.aws_caller_identity.current.account_id
  region           = data.aws_region.current.name
  local_mount_path = "/mnt/efs"
  layer_prefix     = "/opt/nodejs/"
  function_name    = var.alias != null ? aws_lambda_alias.lambda_alias[0].arn : aws_lambda_function.lambda.arn
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
