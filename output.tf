output "lambda" {
  value = aws_lambda_function.lambda
}

output "alias" {
  value = var.alias != null ? aws_lambda_alias.lambda_alias[0] : null
}

output "role" {
  value = aws_iam_role.lambda_builder_iam_role
}
