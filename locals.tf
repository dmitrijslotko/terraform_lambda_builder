locals {
  stage               = terraform.workspace == "default" ? "dev" : terraform.workspace
  is_prod             = terraform.workspace == "prod" ? true : false
  stack_name          = "${var.stack_name}-${local.stage}"
  nodejs_path         = "${path.module}/lambda_code/layer/nodejs"
  nodejs_windows_path = "${path.module}\\lambda_code\\layer\\nodejs"
}
