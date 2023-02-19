resource "aws_iam_role" "lambda_builder_iam_role" {
  count = var.config.role_arn == null ? 1 : 0
  name  = var.config.function_name
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

  dynamic "inline_policy" {
    for_each = var.log_group_config == null ? [] : ["a sigle element to trigger the block"]
    content {
      name = "cloudwatch_logs"

      policy = jsonencode(
        {
          "Statement" : [{
            "Action" : [
              "logs:CreateLogStream",
              "logs:PutLogEvents"
            ],
            "Resource" : "arn:aws:logs:${local.region}:${local.account_id}:log-group:${aws_cloudwatch_log_group.log[0].name}:*",
            "Effect" : "Allow"
          }]
      })
    }

  }

  dynamic "inline_policy" {
    for_each = var.vpc_config != null ? [] : ["a sigle element to trigger the block"]
    content {
      name = "vpc_access_execution_role"
      policy = jsonencode(
        {
          "Version" : "2012-10-17",
          "Statement" : [
            {
              "Effect" : "Allow",
              "Action" : [
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface",
                "ec2:AssignPrivateIpAddresses",
                "ec2:UnassignPrivateIpAddresses"
              ],
              "Resource" : "*",
            }
          ]
      })
    }
  }
}

