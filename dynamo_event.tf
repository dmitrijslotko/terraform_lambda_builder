resource "aws_lambda_event_source_mapping" "dynamo_trigger" {
  count                              = var.dynamo_event_trigger == null ? 0 : 1
  event_source_arn                   = var.dynamo_event_trigger.dynamo_stream_arn
  function_name                      = local.function_name
  starting_position                  = var.dynamo_event_trigger.starting_position
  batch_size                         = var.dynamo_event_trigger.batch_size
  enabled                            = var.dynamo_event_trigger.enabled
  maximum_batching_window_in_seconds = var.dynamo_event_trigger.maximum_batching_window_in_seconds
  maximum_record_age_in_seconds      = var.dynamo_event_trigger.maximum_record_age_in_seconds
  maximum_retry_attempts             = var.dynamo_event_trigger.maximum_retry_attempts
  parallelization_factor             = var.dynamo_event_trigger.parallelization_factor
  tumbling_window_in_seconds         = var.dynamo_event_trigger.tumbling_window_in_seconds
  starting_position_timestamp        = var.dynamo_event_trigger.starting_position_timestamp
  bisect_batch_on_function_error     = var.dynamo_event_trigger.bisect_batch_on_function_error
  function_response_types            = var.dynamo_event_trigger.function_response_types

  dynamic "destination_config" {
    for_each = var.dynamo_event_trigger.on_failure_destination_sqs_arn == null ? [] : ["a sigle element to trigger the block"]
    content {
      on_failure {
        destination_arn = var.dynamo_event_trigger.on_failure_destination_sqs_arn
      }
    }
  }

  dynamic "filter_criteria" {
    for_each = var.dynamo_event_trigger.filter_criteria_pattern == null ? [] : ["a sigle element to trigger the block"]
    content {
      filter {
        pattern = var.dynamo_event_trigger.filter_criteria_pattern
      }
    }
  }
}

resource "aws_lambda_permission" "allow_dynamodb_stream" {
  statement_id  = "dynamodb_permissions"
  action        = "lambda:InvokeFunction"
  function_name = local.function_name
  principal     = "dynamodb.amazonaws.com"
  source_arn    = var.dynamo_event_trigger.dynamo_stream_arn
}
