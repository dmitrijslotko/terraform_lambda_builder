locals {
  account_id   = data.aws_caller_identity.current.account_id
  region       = data.aws_region.current.name
  layer_prefix = "/opt/nodejs/"
  function_name = try(
    aws_lambda_alias.lambda_alias[0].function_name,
    aws_lambda_function.lambda.function_name
  )
  arn = try(
    aws_lambda_alias.lambda_alias[0].arn,
    aws_lambda_function.lambda.arn
  )
  invoke_arn = try(
    aws_lambda_alias.lambda_alias[0].invoke_arn,
    aws_lambda_function.lambda.invoke_arn
  )
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_default_tags" "tags" {}
