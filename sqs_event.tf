resource "aws_lambda_event_source_mapping" "sqs" {
  count            = var.sqs_event_trigger == null ? 0 : 1
  event_source_arn = var.sqs_event_trigger.sqs_arn
  function_name    = local.function_name
}
