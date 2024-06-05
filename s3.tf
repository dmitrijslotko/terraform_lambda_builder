
resource "aws_s3_object" "lambda_source" {
  count  = var.s3_source_config == null ? 0 : 1
  bucket = var.s3_source_config.bucket
  key    = var.s3_source_config.key
  source = data.archive_file.archive[0].output_path
  etag   = data.archive_file.archive[0].output_base64sha256
}

data "archive_file" "archive" {
  count       = var.docker_config != null ? 0 : 1
  type        = "zip"
  source_dir  = var.config.filename
  output_path = "${path.module}/.build/${var.config.function_name}.zip"
}

output "archive_path" {
  value = try(data.archive_file.archive[0].output_path, null)
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count  = var.s3_event_trigger == null ? 0 : 1
  bucket = var.s3_event_trigger.bucket_name

  lambda_function {
    lambda_function_arn = local.arn
    events              = var.s3_event_trigger.events
    filter_prefix       = var.s3_event_trigger.filter_prefix
    filter_suffix       = var.s3_event_trigger.filter_suffix
  }

  depends_on = [
    aws_lambda_permission.s3_permissions,
    aws_lambda_function.lambda,
    time_sleep.s3_permissions
  ]
}
resource "time_sleep" "s3_permissions" {
  count           = var.s3_event_trigger == null ? 0 : 1
  depends_on      = [aws_lambda_permission.s3_permissions]
  create_duration = "3s"
}

resource "aws_lambda_permission" "s3_permissions" {
  count         = var.s3_event_trigger == null ? 0 : 1
  statement_id  = "s3_permissions"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  qualifier     = try(aws_lambda_alias.lambda_alias[0].name, null)
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.s3_event_trigger.bucket_name}"
}
