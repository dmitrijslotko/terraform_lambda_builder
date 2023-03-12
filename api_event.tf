resource "aws_lambda_permission" "api" {
  count         = var.api_event_trigger == null ? 0 : length(local.alias_and_stable_version)
  statement_id  = "api_permissions"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  qualifier     = local.alias_and_stable_version[count.index]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${local.region}:${local.account_id}:${var.api_event_trigger.api_id}/${var.api_event_trigger.stage}/${upper(var.api_event_trigger.http_method)}/${var.api_event_trigger.resource_path}"
}


resource "aws_lambda_permission" "appsync" {
  count         = var.appsync_event_trigger == null ? 0 : length(local.alias_and_stable_version)
  statement_id  = "appsync_permissions"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  qualifier     = local.alias_and_stable_version[count.index]
  principal     = "appsync.amazonaws.com"
  source_arn    = "arn:aws:appsync:${local.region}:${local.account_id}:apis/${var.appsync_event_trigger.api_id}"
}
