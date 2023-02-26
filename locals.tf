locals {
  account_id   = data.aws_caller_identity.current.account_id
  region       = data.aws_region.current.name
  
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
  function_names = concat(
    try([aws_lambda_alias.lambda_alias[0].name], [aws_lambda_function.lambda.function_name]),
    try(["${aws_lambda_function.lambda.function_name}:${var.alias_config.stable_version}"],
  []))
  arns = concat(
    try([aws_lambda_alias.lambda_alias[0].arn], [aws_lambda_function.lambda.arn]),
    try(["${aws_lambda_function.lambda.arn}:${var.alias_config.stable_version}"],
  []))

  alias_and_stable_version = concat(
    try([aws_lambda_alias.lambda_alias[0].name], [aws_lambda_function.lambda.function_name]),
  try([var.alias_config.stable_version], []))
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_default_tags" "tags" {}
