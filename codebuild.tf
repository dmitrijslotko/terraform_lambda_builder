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
    buildspec = fileexists("${var.file_name}/buildspec.yml") ? null : "${file("${path.module}/buildspec.yml")}"
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }
}

resource "null_resource" "codebuild_status_check" {
  count = local.docker_lambda_count

  provisioner "local-exec" {
    working_dir = path.module
    command     = "aws codebuild list-builds-for-project --project-name ${var.function_name} --max-items 1 > project_builds_${var.function_name}.json"
    on_failure  = continue
  }

  provisioner "local-exec" {
    working_dir = path.module
    command     = "aws codebuild batch-get-builds --ids ${try(jsondecode(file("${path.module}/project_builds_${var.function_name}.json")).ids[0], "${var.function_name}:${random_uuid.random.id}")} > last_build_result_${var.function_name}.json"
    on_failure  = continue
  }

  triggers = {
    etag = timestamp()
  }
}

resource "null_resource" "codebuild_start" {
  count = local.docker_lambda_count
  triggers = {
    status = try("${jsondecode(file("${path.module}/last_build_result_${var.function_name}.json")).builds[0].buildStatus}" == "SUCCEEDED" ? "no_build" : timestamp(), timestamp())
    etag   = aws_s3_bucket_object.docker_artifact[count.index].etag
  }

  provisioner "local-exec" {
    working_dir = path.module
    command     = "npm i"
  }

  provisioner "local-exec" {
    working_dir = path.module
    command     = "node codebuild_launch.js ${var.function_name} ${local.region} "
  }

  depends_on = [
    aws_codebuild_project.project[0],
    aws_ecr_repository.ecr[0],
    null_resource.codebuild_status_check[0]
  ]
}


resource "random_uuid" "random" {}