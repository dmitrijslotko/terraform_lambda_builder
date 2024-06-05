resource "aws_ecr_repository" "repo" {
  count                = var.docker_config != null ? 1 : 0
  name                 = var.config.function_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "repo_policy" {
  count      = var.docker_config != null ? 1 : 0
  repository = aws_ecr_repository.repo[0].name

  policy = jsonencode(
    {
      "rules" : [
        {
          "rulePriority" : 1,
          "description" : "remove unttaged images",
          "selection" : {
            "tagStatus" : "untagged",
            "countType" : "imageCountMoreThan",
            "countNumber" : 1
          },
          "action" : {
            "type" : "expire"
          }
        }
      ]
    }
  )
}
