output "lambda" {
  value = aws_lambda_function.lambda
}

output "alias" {
  value = try(aws_lambda_alias.lambda_alias[0], null)
}

output "role" {
  value = aws_iam_role.lambda_builder_iam_role[0]
}

output "arn" {
  value = local.arn
}

output "invoke_arn" {
  value = local.invoke_arn
}

output "function_name" {
  value = local.function_name
}
