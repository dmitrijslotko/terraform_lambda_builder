output "lambda_output" {
  value = var.deploy_mode == "SAM" ? data.aws_lambda_function.existing : aws_lambda_function.lambda[0]
}

data "aws_lambda_function" "existing" {
  function_name = var.function_name
}
