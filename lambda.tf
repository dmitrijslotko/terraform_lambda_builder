
resource "aws_lambda_function" "lambda" {
  filename         = fileexists("${var.file_name}/Dockerfile") ? null : data.archive_file.archive.output_path
  function_name    = var.function_name
  source_code_hash = data.archive_file.archive.output_base64sha256
  role             = var.lambda_role
  handler          = length(var.lambda_handler) > 1? var.lambda_handler : var.default_lambda_handler
  timeout          = try(var.lambda_timeout, var.default_lambda_timeout)
  runtime          = try(var.lambda_runtime, var.default_lambda_runtime)
  memory_size      = var.lambda_memory < 256 || var.lambda_memory > 1024 * 10 ? var.default_lambda_memory : var.lambda_memory
  layers = concat(
      var.layers == null?  [""] : var.layers,
      var.default_layers,      
    ) 
  reserved_concurrent_executions = try(var.reserved_concurrent_executions, -1) 
  environment {
    variables = merge(
      var.default_enviroment_variables,
      var.enviroment_variables
    ) 
  }
  tags = merge(
      var.default_tags,
      var.lambda_tags
    ) 
}

resource "aws_cloudwatch_log_group" "log" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.lambda_retention_in_days
  tags = merge(
      var.default_tags,
      var.lambda_tags
    ) 
}

data "archive_file" "archive" {
  type        = "zip"
  source_dir  = var.file_name
  output_path = "${path.module}/.build/${var.function_name}.zip"
}