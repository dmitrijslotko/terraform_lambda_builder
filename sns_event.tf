resource "aws_lambda_permission" "sns_permissions" {
  count         = var.sns_event_config == null ? 0 : length(local.alias_and_stable_version)
  statement_id  = "sns_permissions"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  qualifier     = local.alias_and_stable_version[count.index]
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_event_config.topic_arn
}

resource "aws_sns_topic_subscription" "sns_subscription" {
  count     = var.sns_event_config == null ? 0 : length(local.arns)
  topic_arn = var.sns_event_config.topic_arn
  protocol  = "lambda"
  endpoint  = local.arns[count.index]
}
