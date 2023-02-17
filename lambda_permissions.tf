resource "aws_lambda_permission" "appsync_permissions" {
  count         = var.appsync_source_arn == null ? 0 : 1
  statement_id  = "appsync_permissions"
  action        = "lambda:InvokeFunction"
  function_name = local.function_name
  principal     = "appsync.amazonaws.com"
  source_arn    = var.appsync_source_arn
}

resource "aws_lambda_permission" "api_gw_permissions" {
  count         = var.api_gw_source_arn == null ? 0 : 1
  statement_id  = "api_gw_permissions"
  action        = "lambda:InvokeFunction"
  function_name = local.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = var.api_gw_source_arn
}

resource "aws_lambda_permission" "s3_permissions" {
  count         = var.s3_notification_bucket_name == null ? 0 : 1
  statement_id  = "s3_permissions"
  action        = "lambda:InvokeFunction"
  function_name = local.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.s3_notification_bucket_name}"
}

resource "aws_lambda_permission" "sqs_permissions" {
  count         = var.sqs_source_arn == null ? 0 : 1
  statement_id  = "sqs_permissions"
  action        = "lambda:InvokeFunction"
  function_name = local.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = var.sqs_source_arn
}



