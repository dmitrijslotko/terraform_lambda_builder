data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "service_role" {
  count = local.docker_lambda_count
  name  = "${var.function_name}_service_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "service_policy" {
  count  = local.docker_lambda_count
  role   = aws_iam_role.service_role[count.index].name
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion"
      ],
      "Resource": [
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
    }
  ]
}
POLICY
}