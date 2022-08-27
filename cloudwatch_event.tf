resource "aws_cloudwatch_event_rule" "rule" {
  count               = local.cw_rule ? 1 : 0
  name                = var.function_name
  schedule_expression = var.cw_event_cron_expression
  is_enabled          = var.cw_event_is_enabled
}

resource "aws_cloudwatch_event_target" "target" {
  count = local.cw_rule ? 1 : 0
  rule  = aws_cloudwatch_event_rule.rule.name
  arn   = local.arn
  input = var.cw_event_input
}
