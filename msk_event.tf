resource "aws_lambda_event_source_mapping" "msk_trigger" {
  count             = var.msk_event_trigger == null ? 0 : 1
  event_source_arn  = var.msk_event_trigger.cluster_arn
  function_name     = local.arn
  starting_position = var.msk_event_trigger.starting_position
  batch_size        = var.msk_event_trigger.batch_size
  enabled           = var.msk_event_trigger.enabled
  topics            = [var.msk_event_trigger.topic]
}
