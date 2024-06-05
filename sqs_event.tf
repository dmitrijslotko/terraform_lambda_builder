resource "aws_lambda_event_source_mapping" "sqs" {
  count                              = var.sqs_event_trigger == null ? 0 : 1
  event_source_arn                   = var.sqs_event_trigger.sqs_arn
  function_name                      = local.arn
  function_response_types            = var.sqs_event_trigger.function_response_types
  maximum_batching_window_in_seconds = var.sqs_event_trigger.maximum_batching_window_in_seconds
  scaling_config {
    maximum_concurrency = var.sqs_event_trigger.maximum_concurrency
  }

  dynamic "filter_criteria" {
    for_each = var.sqs_event_trigger.filter_criteria_pattern == null ? [] : ["a sigle element to trigger the block"]
    content {
      filter {
        pattern = var.sqs_event_trigger.filter_criteria_pattern
      }
    }
  }
}
