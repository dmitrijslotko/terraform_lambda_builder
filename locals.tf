locals {
  is_docker_lambda    = fileexists("${var.file_name}/Dockerfile")
  docker_lambda_count = local.is_docker_lambda == true ? 1 : 0
  docker_artifact     = var.artifact_path == null ? "${var.function_name}_docker_artifact.zip" : "${var.artifact_path}/${var.function_name}_docker_artifact.zip"
  account_id          = data.aws_caller_identity.current.account_id
  region              = data.aws_region.current.name
  local_mount_path    = "/mnt/efs"
}