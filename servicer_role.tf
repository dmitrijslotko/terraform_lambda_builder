data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "service_role" {
  count = var.deploy_mode == "SAM" ? 1 : 0
  name  = "${var.function_name}_service_role"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : ["codebuild.amazonaws.com", "codedeploy.amazonaws.com", "events.amazonaws.com"]
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
  inline_policy {
    name = "permissions"
    policy = jsonencode(
      {
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Effect" : "Allow",
            "Action" : [
              "s3:GetObject",
              "s3:GetObjectVersion",
              "s3:PutObject"
            ],
            "Resource" : [
              "arn:aws:s3:::${var.artifact_bucket}",
              "arn:aws:s3:::${var.artifact_bucket}/*"
            ]
          },
          {
            "Effect" : "Allow",
            "Action" : [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents",
              "codebuild:*",
              "ecr:*",
              "cloudformation:*",
              "*",
              "lambda:*",
              "sns:Publish",
              "iam:PassRole",
              "iam:CreateRole",
              "iam:AttachRolePolicy",
              "iam:DetachRolePolicy",
              "codedeploy:*"
            ],
            "Resource" : "*"
          },
          {
            "Action" : [
              "lambda:InvokeFunction"
            ],
            "Resource" : "arn:aws:lambda:*:*:function:CodeDeployHook_*",
            "Effect" : "Allow"
          }
        ]
    })
  }
}
