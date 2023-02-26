resource "aws_cloudwatch_event_rule" "rule" {
  count               = var.cron_config == null ? 0 : 1
  schedule_expression = var.cron_config.cron_expression
  is_enabled          = var.cron_config.enabled
  name                = var.config.function_name
}

resource "aws_cloudwatch_event_target" "target" {
  count = var.cron_config == null ? 0 : length(local.arns)
  rule  = aws_cloudwatch_event_rule.rule[0].name
  arn   = local.arns[count.index]
  input = var.cron_config.input
}

resource "aws_lambda_permission" "cw_permissions" {
  count         = var.cron_config == null ? 0 : length(local.alias_and_stable_version)
  statement_id  = "cloudwatch_permissions"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  qualifier     = local.alias_and_stable_version[count.index]
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rule[0].arn
}
