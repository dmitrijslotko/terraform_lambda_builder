resource "aws_cloudwatch_metric_alarm" "anomaly_detection" {
  count               = try(var.alarm_config.type == "anomaly_detection" ? 1 : 0, 0)
  alarm_name          = var.alarm_config.name == null ? "${var.alarm_config.priority}_${var.config.function_name}" : var.alarm_config.name
  alarm_actions       = try([var.alarm_config.sns_topic_arn], var.alarm_config.alarm_actions)
  ok_actions          = try([var.alarm_config.sns_topic_arn], var.alarm_config.alarm_actions)
  comparison_operator = "LessThanLowerOrGreaterThanUpperThreshold"
  treat_missing_data  = var.alarm_config.treat_missing_data
  threshold_metric_id = "ad1"
  datapoints_to_alarm = var.alarm_config.datapoints_to_alarm
  evaluation_periods  = var.alarm_config.evaluation_periods
  actions_enabled     = var.alarm_config.actions_enabled

  metric_query {
    id = "m1"
    metric {
      metric_name = "Throttles"
      namespace   = "AWS/Lambda"
      period      = var.alarm_config.period
      stat        = "Sum"
      dimensions = {
        FunctionName = var.config.function_name
      }
    }
  }

  metric_query {
    id = "m2"
    metric {
      metric_name = "Errors"
      namespace   = "AWS/Lambda"
      period      = var.alarm_config.period
      stat        = "Sum"
      dimensions = {
        FunctionName = var.config.function_name
      }
    }
  }

  metric_query {
    id = "m3"
    metric {
      metric_name = "Invocations"
      namespace   = "AWS/Lambda"
      period      = var.alarm_config.period
      stat        = "Average"
      dimensions = {
        FunctionName = var.config.function_name
      }
    }
  }
  metric_query {
    id = "m4"
    metric {
      metric_name = "Duration"
      namespace   = "AWS/Lambda"
      period      = var.alarm_config.period
      stat        = "Average"
      dimensions = {
        FunctionName = var.config.function_name
      }
    }
  }

  metric_query {
    id = "m5"
    metric {
      metric_name = "ConcurrentExecutions"
      namespace   = "AWS/Lambda"
      period      = var.alarm_config.period
      stat        = "Average"
      dimensions = {
        FunctionName = var.config.function_name
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
    expression  = "ANOMALY_DETECTION_BAND(e2,${var.alarm_config.normal_deviation})"
    label       = "deviation level"
    return_data = "true"
  }
}

resource "aws_cloudwatch_metric_alarm" "error_detection" {
  count               = try(var.alarm_config.type == "error_detection" ? 1 : 0, 0)
  comparison_operator = "GreaterThanThreshold"
  alarm_name          = var.alarm_config.name == null ? "${var.alarm_config.priority}_${var.config.function_name}" : var.alarm_config.name
  alarm_actions       = try([var.alarm_config.sns_topic_arn], var.alarm_config.alarm_actions)
  ok_actions          = try([var.alarm_config.sns_topic_arn], var.alarm_config.alarm_actions)
  treat_missing_data  = var.alarm_config.treat_missing_data
  threshold           = "0"
  datapoints_to_alarm = var.alarm_config.datapoints_to_alarm
  evaluation_periods  = var.alarm_config.evaluation_periods
  actions_enabled     = var.alarm_config.actions_enabled

  metric_query {
    id = "m1"
    metric {
      metric_name = "Throttles"
      namespace   = "AWS/Lambda"
      period      = 60
      stat        = "Sum"
      dimensions = {
        FunctionName = var.config.function_name
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
        FunctionName = var.config.function_name
      }
    }
  }

  metric_query {
    id          = "e1"
    expression  = "m1 + m2"
    return_data = "true"
  }
}

resource "aws_cloudwatch_metric_alarm" "daily_check" {
  count               = try(var.alarm_config.type == "daily_check" ? 1 : 0, 0)
  alarm_name          = var.alarm_config.name == null ? "${var.alarm_config.priority}_${var.config.function_name}" : var.alarm_config.name
  threshold           = 0
  evaluation_periods  = 288
  datapoints_to_alarm = 288
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "breaching"
  alarm_actions       = try([var.alarm_config.sns_topic_arn], var.alarm_config.alarm_actions)
  ok_actions          = try([var.alarm_config.sns_topic_arn], var.alarm_config.alarm_actions)

  metric_query {
    id = "m1"
    metric {
      metric_name = "Throttles"
      namespace   = "AWS/Lambda"
      period      = 300
      stat        = "Sum"
      dimensions = {
        FunctionName = var.config.function_name
      }
    }
  }

  metric_query {
    id = "m2"
    metric {
      metric_name = "Errors"
      namespace   = "AWS/Lambda"
      period      = 300
      stat        = "Sum"
      dimensions = {
        FunctionName = var.config.function_name
      }
    }
  }

  metric_query {
    id          = "e1"
    expression  = "m1 + m2"
    return_data = "true"
  }
}

resource "aws_cloudwatch_metric_alarm" "custom" {
  count               = try(var.alarm_config.type == "custom" ? 1 : 0, 0)
  comparison_operator = var.alarm_config.comparison_operator
  alarm_name          = var.alarm_config.name == null ? "${var.alarm_config.priority}_${var.config.function_name}" : var.alarm_config.name
  alarm_actions       = try([var.alarm_config.sns_topic_arn], var.alarm_config.alarm_actions)
  ok_actions          = try([var.alarm_config.sns_topic_arn], var.alarm_config.alarm_actions)
  treat_missing_data  = var.alarm_config.treat_missing_data
  threshold           = var.alarm_config.threshold
  datapoints_to_alarm = var.alarm_config.datapoints_to_alarm
  evaluation_periods  = var.alarm_config.evaluation_periods
  actions_enabled     = var.alarm_config.actions_enabled
  metric_name         = var.alarm_config.metric_name
  namespace           = var.alarm_config.namespace
  statistic           = var.alarm_config.statistic
  period              = var.alarm_config.period
  threshold_metric_id = var.alarm_config.threshold_metric_id
  dimensions          = var.alarm_config.dimensions
  dynamic "metric_query" {
    for_each = var.alarm_config.metric_query == null ? [] : var.alarm_config.metric_query
    content {
      id          = for_each.value.id
      expression  = for_each.value.expression
      return_data = for_each.value.return_data
      label       = for_each.value.label
      dynamic "metric" {
        for_each = metric_query.value.metric
        content {
          metric_name = metric.metric_name
          namespace   = metric.namespace
          period      = metric.period
          stat        = metric.stat
          dimensions  = metric.dimensions
        }
      }
    }
  }
}
