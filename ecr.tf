resource "aws_ecr_repository" "ecr" {
  count                = local.count
  name                 = var.function_name
  image_tag_mutability = "MUTABLE"
  tags = merge(
    local.default_tags,
    var.tags
  )
}

resource "aws_ecr_lifecycle_policy" "policy" {
  count      = local.count
  repository = aws_ecr_repository.ecr[count.index].name
  policy     = <<EOF
  {
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last ${local.image_count} images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": ${local.image_count}
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
  count           = local.count
  repository_name = aws_ecr_repository.ecr[count.index].name
  image_tag       = "latest"

  depends_on = [
    null_resource.codebuild_start
  ]
}