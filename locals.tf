locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  function_name = try(
    aws_lambda_alias.lambda_alias[0].function_name,
    aws_lambda_function.lambda.function_name
  )
  arn = try(
    aws_lambda_alias.lambda_alias[0].arn,
    aws_lambda_function.lambda.version == "$LATEST" || aws_lambda_function.lambda.publish == false ? aws_lambda_function.lambda.arn : "${aws_lambda_function.lambda.arn}:${aws_lambda_function.lambda.version}"
  )
  invoke_arn = try(
    aws_lambda_alias.lambda_alias[0].invoke_arn,
    aws_lambda_function.lambda.invoke_arn
  )

  lambda_function_qualifier = try(aws_lambda_alias.lambda_alias[0].name, aws_lambda_function.lambda.version == "$LATEST" || aws_lambda_function.lambda.publish == false ? null : aws_lambda_function.lambda.version)
  layer_prefix              = strcontains(var.config.runtime, "nodejs") ? "/opt/nodejs/" : strcontains(var.config.runtime, "python") ? "/opt/python/" : "/opt/"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_default_tags" "tags" {}
