data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "service_role" {
  count = local.docker_lambda_count == 0 ? var.traffic_routing_type != null ? 1 : 0 : 1
  name  = "${var.function_name}_service_role"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : ["codebuild.amazonaws.com", "codedeploy.amazonaws.com"]
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "service_policy" {
  count = local.docker_lambda_count
  role  = aws_iam_role.service_role[count.index].name
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Resource" : [
            "*"
          ],
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:GetObject",
            "s3:GetObjectVersion"
          ],
          "Resource" : [
            "arn:aws:s3:::${var.artifact_bucket}",
            "arn:aws:s3:::${var.artifact_bucket}/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "codebuild:*"
          ],
          "Resource" : "${aws_codebuild_project.project[count.index].arn}"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ecr:*"
          ],
          "Resource" : "*"
        },
        {
          "Action" : [
            "cloudwatch:DescribeAlarms",
            "lambda:UpdateAlias",
            "lambda:GetAlias",
            "lambda:GetProvisionedConcurrencyConfig",
            "sns:Publish"
          ],
          "Resource" : "*",
          "Effect" : "Allow"
        },
        {
          "Action" : [
            "s3:GetObject",
            "s3:GetObjectVersion"
          ],
          "Resource" : "arn:aws:s3:::*/CodeDeploy/*",
          "Effect" : "Allow"
        },
        {
          "Action" : [
            "s3:GetObject",
            "s3:GetObjectVersion"
          ],
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "s3:ExistingObjectTag/UseWithCodeDeploy" : "true"
            }
          },
          "Effect" : "Allow"
        },
        {
          "Action" : [
            "lambda:InvokeFunction"
          ],
          "Resource" : "arn:aws:lambda:*:*:function:CodeDeployHook_*",
          "Effect" : "Allow"
        }
      ]
    }
  )
}
