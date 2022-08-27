resource "aws_lambda_permission" "appsync_authorizer" {
  count         = var.appsync_authorizer == null ? 0 : 1
  statement_id  = "appsync_authorizer"
  action        = "lambda:InvokeFunction"
  function_name = var.alias != null ? aws_lambda_alias.lambda_alias[0].arn : aws_lambda_function.lambda.arn
  principal     = "appsync.amazonaws.com"
  source_arn    = var.appsync_authorizer
}
