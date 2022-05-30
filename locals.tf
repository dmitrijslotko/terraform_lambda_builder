locals {
  account_id       = data.aws_caller_identity.current.account_id
  region           = data.aws_region.current.name
  local_mount_path = "/mnt/efs"
  layer_prefix     = "/opt/nodejs/"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
