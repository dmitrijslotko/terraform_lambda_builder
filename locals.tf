
locals {
  stage             = terraform.workspace == "default" ? "dev" : terraform.workspace
  is_prod           = terraform.workspace == "prod" ? true : false 
  region            = data.aws_region.current.name
  stack_name      = "${var.stack_name}-${local.stage}"
  account_id        = data.aws_caller_identity.current.account_id 
  nodejs_path = "${path.module}/source_code/layer/nodejs"
}