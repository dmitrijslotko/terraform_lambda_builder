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
  count         = var.s3_source_arn == null ? 0 : 1
  statement_id  = "s3_permissions"
  action        = "lambda:InvokeFunction"
  function_name = local.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_source_arn
}

resource "aws_lambda_permission" "sqs_permissions" {
  count         = var.sqs_source_arn == null ? 0 : 1
  statement_id  = "sqs_permissions"
  action        = "lambda:InvokeFunction"
  function_name = local.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = var.sqs_source_arn
}

resource "aws_lambda_permission" "cw_permissions" {
  count         = local.cw_rule ? 1 : 0
  statement_id  = "cw_permissions"
  action        = "lambda:InvokeFunction"
  function_name = local.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rule[0].arn
}
