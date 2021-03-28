locals {
  default_params = {
    timeout        = 10
    memory         = 256
    handler        = "index.handler"
    lambda_runtime = "nodejs12.x"
    role           = aws_iam_role.iam_role.arn
  }

  lambdas = {
    lambda_example1 = {}
    lambda_example2 = {
      memory  = 512
      timeout = 60
    }
  }
}

data "archive_file" "archive" {
  for_each    = local.lambdas
  type        = "zip"
  source_dir  = "${path.module}/lambda_code/${each.key}"
  output_path = "${path.module}/.build/${each.key}.zip"
}

resource "aws_lambda_function" "lambdas" {
  for_each         = local.lambdas
  filename         = data.archive_file.archive[each.key].output_path
  function_name    = "${each.key}-${local.stack_name}"
  source_code_hash = data.archive_file.archive[each.key].output_base64sha256
  layers           = [aws_lambda_layer_version.lambda_layer.arn]
  role             = try(each.value.role, local.default_params.role)
  handler          = try(each.value.handler, local.default_params.handler)
  timeout          = try(each.value.timeout, local.default_params.timeout)
  runtime          = try(each.value.lambda_runtime, local.default_params.lambda_runtime)
  memory_size      = try(each.value.memory, local.default_params.memory)

  environment {
    variables = {
      stage                      = local.stage
      NODE_ENV                   = "aws"
      SUPPRESS_NO_CONFIG_WARNING = "y"
    }
  }
}

resource "aws_cloudwatch_log_group" "log" {
  for_each          = local.lambdas
  name              = "/aws/lambda/${each.key}"
  retention_in_days = 14
}

resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
