locals {
  image_count      = var.image_count == null ? var.default_image_count : var.image_count
  is_docker_lambda = fileexists("${var.file_name}/Dockerfile")
  count            = fileexists("${var.file_name}/Dockerfile") ? 1 : 0
  docker_artifact  = var.artifact_path == null ? "${var.function_name}_docker_artifact.zip" : "${var.artifact_path}/${var.function_name}_docker_artifact.zip"
  artifact_path    = var.artifact_path == null ? var.default_artifact_path : var.artifact_path
  artifact_bucket  = var.artifact_bucket == null ? var.default_artifact_bucket : var.artifact_bucket
  default_tags     = var.default_tags == null ? { developer = replace(data.aws_caller_identity.current.user_id, "/\\w.*\\:/", "") } : var.default_tags
  account_id       = data.aws_caller_identity.current.account_id
  region           = data.aws_region.current.name
}