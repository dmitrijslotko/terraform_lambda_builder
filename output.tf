output "lambda" {
  value = aws_lambda_function.lambda
}

output "role" {
  value = aws_iam_role.lambda_builder_iam_role
}
