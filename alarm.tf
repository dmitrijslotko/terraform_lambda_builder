resource "aws_cloudwatch_metric_alarm" "anomaly_detection" {
  count               = var.add_alarm == true && var.alarm_type == "anomaly_detection" ? 1 : 0
  alarm_name          = "${var.alarm_priority}_${var.function_name}_anomaly_detection"
  alarm_actions       = [var.sns_topic]
  ok_actions          = [var.sns_topic]
  comparison_operator = "GreaterThanUpperThreshold"
  treat_missing_data  = var.treat_missing_data
  threshold_metric_id = "ad1"
  evaluation_periods  = var.evaluation_periods
  actions_enabled     = var.actions_enabled

  metric_query {
    id = "m1"
    metric {
      metric_name = "Throttles"
      namespace   = "AWS/Lambda"
      period      = var.period
      stat        = "Sum"
      dimensions = {
        FunctionName = var.function_name
      }
    }
  }

  metric_query {
    id = "m2"
    metric {
      metric_name = "Errors"
      namespace   = "AWS/Lambda"
      period      = var.period
      stat        = "Sum"
      dimensions = {
        FunctionName = var.function_name
      }
    }
  }

  metric_query {
    id = "m3"
    metric {
      metric_name = "Invocations"
      namespace   = "AWS/Lambda"
      period      = var.period
      stat        = "Average"
      dimensions = {
        FunctionName = var.function_name
      }
    }
  }
  metric_query {
    id = "m4"
    metric {
      metric_name = "Duration"
      namespace   = "AWS/Lambda"
      period      = var.period
      stat        = "Average"
      dimensions = {
        FunctionName = var.function_name
      }
    }
  }

  metric_query {
    id = "m5"
    metric {
      metric_name = "ConcurrentExecutions"
      namespace   = "AWS/Lambda"
      period      = var.period
      stat        = "Average"
      dimensions = {
        FunctionName = var.function_name
      }
    }
  }

  metric_query {
    id         = "e1"
    expression = "m5 * m4 * m3"
  }

  metric_query {
    id          = "e2"
    expression  = "(CEIL(m1) * e1 * 2) + (CEIL(m2) * e1 * 2) + e1"
    return_data = "true"
  }

  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(e2,${var.normal_deviation})"
    label       = "deviation level"
    return_data = "true"
  }
}

resource "aws_cloudwatch_metric_alarm" "error_detection" {
  count               = var.add_alarm == true && var.alarm_type == "error_detection" ? 1 : 0
  comparison_operator = "GreaterThanThreshold"
  alarm_name          = "${var.alarm_priority}_${var.function_name}_error_detection"
  alarm_actions       = [var.sns_topic]
  ok_actions          = [var.sns_topic]
  treat_missing_data  = var.treat_missing_data
  threshold           = "0"
  evaluation_periods  = var.evaluation_periods
  actions_enabled     = var.actions_enabled

  metric_query {
    id = "m1"
    metric {
      metric_name = "Throttles"
      namespace   = "AWS/Lambda"
      period      = 60
      stat        = "Sum"
      dimensions = {
        FunctionName = var.function_name
      }
    }
  }

  metric_query {
    id = "m2"
    metric {
      metric_name = "Errors"
      namespace   = "AWS/Lambda"
      period      = 60
      stat        = "Sum"
      dimensions = {
        FunctionName = var.function_name
      }
    }
  }

  metric_query {
    id          = "e1"
    expression  = "errors + throttles"
    return_data = "true"
  }
}
