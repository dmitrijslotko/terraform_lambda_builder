
output "lambda_output" {
  value = aws_lambda_function.lambda
}

output "role_output" {
  value = aws_iam_role.lambda_builder_iam_role
}
