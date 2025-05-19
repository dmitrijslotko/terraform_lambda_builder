resource "aws_iam_role" "lambda_builder_iam_role" {
  count = var.config.role_arn == null ? 1 : 0
  name  = var.config.function_name
  tags  = var.config.tags
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
    for_each = var.config.role_policy == null ? [] : ["a sigle element to trigger the block"]
    content {
      name   = "lambda_execution_role"
      policy = var.config.role_policy
    }
  }

  dynamic "inline_policy" {
    for_each = var.secrets_manager_usage_permission == null ? [] : ["a single element to trigger the block"]
    content {
      name = "secrets_manager_access"

      policy = jsonencode(
        {
          "Version" : "2012-10-17",
          "Statement" : [
            {
              "Effect" : "Allow",
              "Action" : [
                "secretsmanager:GetSecretValue",
              ],
              "Resource" : var.secrets_manager_usage_permission.secret_arn
            }
          ]
      })
    }
  }

  dynamic "inline_policy" {
    for_each = var.dynamo_event_trigger == null ? [] : ["a sigle element to trigger the block"]
    content {
      name = "dynamodb_access_execution_role"
      policy = jsonencode(
        {
          "Version" : "2012-10-17",
          "Statement" : [
            {
              "Effect" : "Allow",
              "Action" : [
                "dynamodb:DescribeStream",
                "dynamodb:GetRecords",
                "dynamodb:GetShardIterator",
                "dynamodb:ListStreams"
              ],
              "Resource" : var.dynamo_event_trigger.dynamo_stream_arn
            }
          ]
      })
    }
  }

  dynamic "inline_policy" {
    for_each = var.log_group_config == null ? [] : ["a sigle element to trigger the block"]
    content {
      name = "cloudwatch_logs"

      policy = jsonencode(
        {
          "Version" : "2012-10-17",
          "Statement" : [{
            "Action" : [
              "logs:CreateLogStream",
              "logs:PutLogEvents"
            ],
            "Resource" : "${aws_cloudwatch_log_group.log[0].arn}:*",
            "Effect" : "Allow"
            },
            {
              "Action" : [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*"
              ],
              "Resource" : "*",
              "Effect" : "Allow"
          }]
      })
    }
  }

  dynamic "inline_policy" {
    for_each = var.s3_target_config == null ? [] : ["a sigle element to trigger the block"]
    content {
      name = "s3_access_execution_role"
      policy = jsonencode(
        {
          "Version" : "2012-10-17",
          "Statement" : [
            {
              "Effect" : "Allow",
              "Action" : [
                "s3-object-lambda:*"
              ],
              "Resource" : var.s3_target_config.targets
            }
          ]
      })
    }
  }

  dynamic "inline_policy" {
    for_each = var.lambda_target_config == null ? [] : ["a sigle element to trigger the block"]
    content {
      name = "dynano_access_execution_role"
      policy = jsonencode(
        {
          "Version" : "2012-10-17",
          "Statement" : [
            {
              "Effect" : "Allow",
              "Action" : [
                "lambda:InvokeFunction"
              ],
              "Resource" : var.lambda_target_config.targets
            }
          ]
      })
    }
  }

  dynamic "inline_policy" {
    for_each = var.step_function_target_config == null ? [] : ["a sigle element to trigger the block"]
    content {
      name = "dynano_access_execution_role"
      policy = jsonencode(
        {
          "Version" : "2012-10-17",
          "Statement" : [
            {
              "Effect" : "Allow",
              "Action" : [
                "states:StartExecution",
                "states:StopExecution",
                "states:StartSyncExecution"
              ],
              "Resource" : var.step_function_target_config.targets
            }
          ]
      })
    }
  }

  dynamic "inline_policy" {
    for_each = var.firehose_target_config == null ? [] : ["a sigle element to trigger the block"]
    content {
      name = "dynano_access_execution_role"
      policy = jsonencode(
        {
          "Version" : "2012-10-17",
          "Statement" : [
            {
              "Effect" : "Allow",
              "Action" : [
                "firehose:PutRecord",
                "firehose:PutRecordBatch"
              ],
              "Resource" : var.firehose_target_config.targets
            }
          ]
      })
    }
  }

  dynamic "inline_policy" {
    for_each = var.dynamo_target_config == null ? [] : ["a sigle element to trigger the block"]
    content {
      name = "dynano_access_execution_role"
      policy = jsonencode(
        {
          "Version" : "2012-10-17",
          "Statement" : [
            {
              "Effect" : "Allow",
              "Action" : [
                "dynamodb:BatchGetItem",
                "dynamodb:ConditionCheckItem",
                "dynamodb:GetItem",
                "dynamodb:GetRecords",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:BatchWriteItem",
                "dynamodb:DeleteItem",
                "dynamodb:PutItem",
                "dynamodb:UpdateItem"
              ],
              "Resource" : var.dynamo_target_config.targets
            }
          ]
      })
    }
  }

  dynamic "inline_policy" {
    for_each = var.sqs_target_config == null ? [] : ["a sigle element to trigger the block"]
    content {
      name = "dynano_access_execution_role"
      policy = jsonencode(
        {
          "Version" : "2012-10-17",
          "Statement" : [
            {
              "Effect" : "Allow",
              "Action" : [
                "sqs:ReceiveMessage",
                "sqs:SendMessage"
              ],
              "Resource" : var.sqs_target_config.targets
            }
          ]
      })
    }
  }

  dynamic "inline_policy" {
    for_each = var.msk_target_config == null ? [] : ["a sigle element to trigger the block"]
    content {
      name = "dynano_access_execution_role"
      policy = jsonencode(
        {
          "Version" : "2012-10-17",
          "Statement" : [
            {
              "Effect" : "Allow",
              "Action" : [
                "kafka-cluster:*",
              ],
              "Resource" : var.msk_target_config.targets
            }
          ]
      })
    }
  }

  dynamic "inline_policy" {
    for_each = var.kinesis_target_config == null ? [] : ["a sigle element to trigger the block"]
    content {
      name = "dynano_access_execution_role"
      policy = jsonencode(
        {
          "Version" : "2012-10-17",
          "Statement" : [
            {
              "Effect" : "Allow",
              "Action" : [
                "kinesis:PutRecord",
                "kinesis:PutRecords",
                "kinesis:DescribeStream"
              ],
              "Resource" : var.kinesis_target_config.targets
            }
          ]
      })
    }
  }

  dynamic "inline_policy" {
    for_each = var.vpc_config == null ? [] : ["a sigle element to trigger the block"]
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
                "ec2:UnassignPrivateIpAddresses",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcs",
              ],
              "Resource" : "*",
            }
          ]
      })
    }
  }

  dynamic "inline_policy" {
    for_each = var.sqs_event_trigger == null ? [] : ["a sigle element to trigger the block"]

    content {
      name = "sqs_trigger"
      policy = jsonencode(
        {
          "Version" : "2012-10-17",
          "Statement" : [
            {
              "Effect" : "Allow",
              "Action" : [
                "sqs:ReceiveMessage",
                "sqs:DeleteMessage",
                "sqs:GetQueueAttributes"
              ],
              "Resource" : var.sqs_event_trigger.sqs_arn
            }
          ]
      })
    }
  }

  dynamic "inline_policy" {
    for_each = var.kinesis_event_trigger == null ? [] : ["a sigle element to trigger the block"]

    content {
      name = "kinesis_trigger"
      policy = jsonencode(
        {
          "Version" : "2012-10-17",
          "Statement" : [
            {
              "Effect" : "Allow",
              "Action" : [
                "kinesis:GetRecords",
                "kinesis:GetShardIterator",
                "kinesis:DescribeStream",
                "kinesis:ListStreams",
                "kinesis:DescribeStreamSummary",
                "kinesis:ListShards",
              ],
              "Resource" : var.kinesis_event_trigger.kinesis_arn
            }
          ]
      })
    }
  }

  dynamic "inline_policy" {
    for_each = var.msk_event_trigger == null ? [] : ["a sigle element to trigger the block"]

    content {
      name = "msk_trigger"
      policy = jsonencode(
        {
          "Version" : "2012-10-17",
          "Statement" : [
            {
              "Effect" : "Allow",
              "Action" : [
                "kafka:DescribeCluster",
                "kafka:GetBootstrapBrokers",
                "kafka:DescribeClusterV2",
                "kafka-cluster:Connect",
                "kafka-cluster:DescribeGroup",
                "kafka-cluster:AlterGroup",
                "kafka-cluster:DescribeTopic",
                "kafka-cluster:ReadData",
                "kafka-cluster:DescribeClusterDynamicConfiguration"
              ],
              "Resource" : "*"
            },
            {
              "Effect" : "Allow",
              "Action" : [
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcs",
              ],
              "Resource" : "*",
            }
          ]
      })
    }
  }
}
