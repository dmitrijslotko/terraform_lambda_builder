# resource "aws_lambda_permission" "appsync_permissions" {
#   count         = var.appsync_source_arn == null ? 0 : 1
#   statement_id  = "appsync_permissions"
#   action        = "lambda:InvokeFunction"
#   function_name = local.function_name
#   principal     = "appsync.amazonaws.com"
#   source_arn    = var.appsync_source_arn
# }

# resource "aws_lambda_permission" "api_gw_permissions" {
#   count         = var.api_gw_source_arn == null ? 0 : 1
#   statement_id  = "api_gw_permissions"
#   action        = "lambda:InvokeFunction"
#   function_name = local.function_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = var.api_gw_source_arn
# }