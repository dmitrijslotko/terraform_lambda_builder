resource "aws_ecr_repository" "ecr" {
  count                = local.docker_lambda_count
  name                 = var.function_name
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_lifecycle_policy" "policy" {
  count      = local.docker_lambda_count
  repository = aws_ecr_repository.ecr[count.index].name
  policy     = <<EOF
  {
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last ${var.image_count} images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": ${var.image_count}
            },
            "action": {
                "type": "expire"
            }
        }
    ]
  }
  EOF
}

data "aws_ecr_image" "image" {
  count           = local.docker_lambda_count
  repository_name = aws_ecr_repository.ecr[count.index].name
  image_tag       = "latest"
  depends_on = [
    null_resource.codebuild_start
  ]
}