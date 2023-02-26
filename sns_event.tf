resource "aws_lambda_permission" "sns_permissions" {
  count         = var.sns_event_config == null ? 0 : 1
  statement_id  = "sns_permissions"
  action        = "lambda:InvokeFunction"
  function_name = local.arn
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_event_config.topic_arn
}

resource "aws_sns_topic_subscription" "sns_subscription" {
  count     = var.sns_event_config == null ? 0 : 1
  topic_arn = var.sns_event_config.topic_arn
  protocol  = "lambda"
  endpoint  = local.arn
}
