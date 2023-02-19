# resource "aws_lambda_event_source_mapping" "sqs" {
#   count            = var.sqs_source_arn == null ? 0 : 1
#   event_source_arn = var.sqs_source_arn
#   function_name    = local.function_name
# }

# resource "aws_lambda_event_source_mapping" "dynamodb" {
#   count             = var.dynamodb_stream_arn == null ? 0 : 1
#   event_source_arn  = var.dynamodb_stream_arn
#   function_name     = local.function_name
#   starting_position = var.dynamodb_stream_starting_position
# }

# resource "aws_lambda_event_source_mapping" "kinesis" {
#   count             = var.kinesis_stream_arn == null ? 0 : 1
#   event_source_arn  = var.kinesis_stream_arn
#   function_name     = local.function_name
#   starting_position = var.kinesis_stream_starting_position
# }

# resource "aws_s3_bucket_notification" "bucket_notification" {
#   count  = var.s3_notification_bucket_name == null ? 0 : 1
#   bucket = var.s3_notification_bucket_name

#   lambda_function {
#     lambda_function_arn = local.arn
#     events              = var.s3_notification_events
#     filter_prefix       = var.s3_notification_filter_prefix
#     filter_suffix       = var.s3_notification_filter_suffix
#   }
# }
