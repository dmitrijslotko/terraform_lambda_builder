resource "aws_cloudwatch_metric_alarm" "lambda_deploy_alarm" {
  count               = var.deploy_mode == "SAM" ? 1 : 0
  alarm_name          = "deploy_alarm_${var.function_name}"
  alarm_actions       = var.sns_topic_arn == null ? null : [var.sns_topic_arn]
  ok_actions          = var.sns_topic_arn == null ? null : [var.sns_topic_arn]
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  threshold           = "1"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  dimensions = {
    FunctionName = var.function_name
    Resource     = "${var.function_name}:${var.alias}"
  }
}
