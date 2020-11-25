locals {
  timeout        = 10
  memory         = 256
  handler        = "index.handler"
  lambda_runtime = "nodejs12.x"
  role = aws_iam_role.iam_role.arn
  lambdas = {
    example1 = {} 
    example2 = {
      memory      = 512
      timeout     = 60
    }    
  }
}

data "archive_file" "archive" {
  for_each    = local.lambdas
  type        = "zip"
  source_dir  = "${path.module}/source_code/lambda_code/${each.key}" 
  output_path = "${path.module}/.build/${each.key}.zip"
}

resource "aws_lambda_function" "lambdas" {
  for_each         = local.lambdas
  filename         = data.archive_file.archive[each.key].output_path
  function_name    = "${each.key}-${local.stack_name}"  
  source_code_hash = data.archive_file.archive[each.key].output_base64sha256
  layers           = [aws_lambda_layer_version.lambda_layer.arn]
  role             = try(each.value.role,local.role)
  handler          = try(each.value.handler,local.handler)
  timeout          = try(each.value.timeout,local.timeout)
  runtime          = try(each.value.lambda_runtime,local.lambda_runtime)
  memory_size      = try(each.value.memory,local.memory)

  environment {
    variables = {
      stage = local.stage      
    }
  }
}