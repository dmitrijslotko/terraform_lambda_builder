resource "aws_codebuild_project" "project" {
  count         = local.docker_lambda_count
  name          = var.function_name
  description   = "automated docker build"
  build_timeout = var.build_timeout
  service_role  = aws_iam_role.service_role[count.index].arn

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    environment_variable {
      name  = "REPOSITORY_URI"
      value = aws_ecr_repository.ecr[count.index].repository_url
    }
  }

  source {
    type      = "S3"
    location  = "${var.artifact_bucket}/${var.artifact_path}/${local.docker_artifact}"
    buildspec = var.is_docker_lambda && var.use_default_buildspec ? file("${path.module}/buildspec.yml") : file("${var.file_name}/buildspec.yml")
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }
}

resource "local_file" "copy_default_buildspec" {
  count    = var.is_docker_lambda && var.use_default_dockerfile ? 1 : 0
  content  = file("${path.module}/Dockerfile")
  filename = "${var.file_name}/Dockerfile"
}

resource "null_resource" "codebuild_start" {
  count = local.docker_lambda_count
  triggers = {
    etag = aws_s3_bucket_object.docker_artifact[count.index].etag
  }

  provisioner "local-exec" {
    working_dir = path.module
    command     = "npm i"
  }

  provisioner "local-exec" {
    working_dir = path.module
    command     = "node codebuild_launch.js ${var.function_name} ${local.region} true"
    on_failure  = fail
  }

  depends_on = [
    aws_codebuild_project.project[0],
    aws_ecr_repository.ecr[0],
  ]
}


resource "random_uuid" "random" {}
