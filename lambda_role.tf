resource "aws_iam_role" "lambda_builder_iam_role" {
  count = var.create_lambda_role ? 1 : 0
  name  = "${var.function_name}_role"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : [
              "lambda.amazonaws.com"
            ]
          },
          "Action" : "sts:AssumeRole"
        }
      ]
  })
}

resource "aws_iam_role_policy" "lambda_builder_permission_policy" {
  count = var.create_lambda_role ? 1 : 0
  name  = "${var.function_name}_policy"
  role  = aws_iam_role.lambda_builder_iam_role[count.index].id

  policy = jsonencode(
    {
      "Statement" : [{
        "Action" : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:${local.region}:${local.account_id}:log-group:${aws_cloudwatch_log_group.log.name}:*",
        "Effect" : "Allow"
      }]
  })
}


resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
  count      = var.subnet_ids == null ? 0 : 1
  role       = aws_iam_role.lambda_builder_iam_role[count.index].id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
