resource "aws_lambda_function" "lambda" {
  filename         = local.is_docker_lambda ? null : data.archive_file.archive.output_path
  image_uri        = local.is_docker_lambda ? "${aws_ecr_repository.ecr[0].repository_url}:${data.aws_ecr_image.image[0].image_tags[1]}" : null
  function_name    = var.function_name
  source_code_hash = data.archive_file.archive.output_base64sha256
  role             = var.lambda_role
  handler          = local.is_docker_lambda ? null : length(var.lambda_handler) > 1 ? var.lambda_handler : var.default_lambda_handler
  timeout          = try(var.lambda_timeout, var.default_lambda_timeout)
  runtime          = local.is_docker_lambda ? null : try(var.lambda_runtime, var.default_lambda_runtime)
  memory_size      = var.lambda_memory < 256 || var.lambda_memory > 1024 * 10 ? var.default_lambda_memory : var.lambda_memory
  package_type     = local.is_docker_lambda ? "Image" : "Zip"
  layers = local.is_docker_lambda ? null : concat(
    var.layers == null ? [""] : var.layers,
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
    local.default_tags,
    var.tags
  )
}

resource "aws_cloudwatch_log_group" "log" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.lambda_retention_in_days
  tags = merge(
    local.default_tags,
    var.tags
  )
}

data "archive_file" "archive" {
  type        = "zip"
  source_dir  = var.file_name
  output_path = "${path.module}/.build/${var.function_name}.zip"
}

resource "aws_s3_bucket_object" "docker_artifact" {
  count  = local.count
  bucket = local.artifact_bucket
  key    = "${local.artifact_path}/${local.docker_artifact}"
  source = data.archive_file.archive.output_path
  etag   = filemd5(data.archive_file.archive.output_path)
  tags = merge(
    local.default_tags,
    var.tags
  )
}

