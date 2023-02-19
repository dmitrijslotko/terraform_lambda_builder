output "lambda" {
  value = aws_lambda_function.lambda
}

output "alias" {
  value = var.alias_config != null ? aws_lambda_alias.lambda_alias[0] : null
}

output "role" {
  value = aws_iam_role.lambda_builder_iam_role
}

output "arn" {
  value = local.arn
}

output "invoke_arn" {
  value = var.alias_config != null ? aws_lambda_alias.lambda_alias[0].invoke_arn : aws_lambda_function.lambda.invoke_arn
}

output "function_name" {
  value = local.function_name
}
