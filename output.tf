output "lambda" {
  value = aws_lambda_function.lambda
}

output "alias" {
  value = aws_lambda_alias.lambda_alias
}

output "role" {
  value = aws_iam_role.lambda_builder_iam_role
}
