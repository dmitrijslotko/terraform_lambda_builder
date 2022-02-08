# ========== Mandatory fields ==========

variable "function_name" {
  type = string
  validation {
    condition     = length(var.function_name) <= 64
    error_message = "The name of the Lambda function, up to 64 characters in length."
  }
}

variable "file_name" {
  type = string
}

# ========== Mandatory fields ==========

# ========== Optional fields ==========

variable "alias" {
  type    = string
  default = null
}

variable "deploy_mode" {
  type    = string
  default = "default"
  validation {
    condition     = var.deploy_mode == "default" || var.deploy_mode == "SAM"
    error_message = "Default deploy supported only for nodejs runtime otherwise chose SAM mode."
  }
}

variable "sns_topic_arn" {
  type    = string
  default = null
}

variable "artifact_key" {
  type    = string
  default = null
}

variable "lambda_runtime" {
  type    = string
  default = "nodejs14.x"
}

variable "role_policy" {
  type    = string
  default = null
}

variable "lambda_memory" {
  type    = number
  default = 256
  validation {
    condition     = var.lambda_memory >= 256 || var.lambda_memory <= 10240
    error_message = "Lambda memory should be between 256 and 10240."
  }
}

variable "lambda_timeout" {
  type    = number
  default = 30

  validation {
    condition     = var.lambda_timeout <= 900
    error_message = "Lambda timeout variable cannot be more than 900 seconds (15 minutes)."
  }
}

variable "lambda_handler" {
  type    = string
  default = "index.handler"
}

variable "cloudwatch_log_retention_in_days" {
  type    = number
  default = 30
}

variable "enviroment_variables" {
  type = map(string)
  default = {
    layer_prefix = "/opt/nodejs/"
  }
}

variable "reserved_concurrent_executions" {
  type    = number
  default = -1
}

variable "layers" {
  type    = list(string)
  default = [""]
}

variable "gradual_deployment_type" {
  type    = string
  default = "AllAtOnce"

  validation {
    condition     = contains(["AllAtOnce", "Canary10Percent30Minutes", "Canary10Percent5Minutes", "Canary10Percent10Minutes", "Canary10Percent15Minutes", "Linear10PercentEvery10Minutes", "Linear10PercentEvery1Minute", "Linear10PercentEvery2Minutes", "Linear10PercentEvery3Minutes"], var.gradual_deployment_type)
    error_message = "Type should be one of the following: AllAtOnce, Canary10Percent30Minutes, Canary10Percent5Minutes, Canary10Percent10Minutes, Canary10Percent15Minutes, Linear10PercentEvery10Minutes, Linear10PercentEvery1Minute, Linear10PercentEvery2Minutes, Linear10PercentEvery3Minutes."
  }
}

variable "gradual_deployment" {
  type    = bool
  default = true
}

# ========== Optional fields ==========

# ========== VPC related fields ==========

variable "subnet_ids" {
  type    = list(string)
  default = null
}

variable "security_group_ids" {
  type    = list(string)
  default = null
}

# ========== VPC related fields ==========

# ========== EFS related fields ==========

variable "efs_access_point" {
  type    = string
  default = null
}

variable "local_mount_path" {
  type    = string
  default = "/mnt/efs"
}

variable "add_efs" {
  type    = bool
  default = false
}

# ========== EFS related fields ==========

# ========== Image lambda fields ==========
variable "image_count" {
  type    = number
  default = 5
}

variable "is_docker_lambda" {
  type    = bool
  default = false
}

variable "use_default_buildspec" {
  type    = bool
  default = false
}

variable "use_default_dockerfile" {
  type    = bool
  default = false
}

variable "artifact_bucket" {
  type    = string
  default = null
}

variable "artifact_path" {
  type    = string
  default = "_artifacts_"
}

variable "build_timeout" {
  type    = number
  default = 10
}

variable "lambda_role_arn" {
  type    = string
  default = null
}

# ========== Image lambda fields ==========

# ========== Deployment fields ==========

variable "routing_interval" {
  type    = number
  default = 60
}

variable "routing_percentage" {
  type    = number
  default = 10
}
variable "traffic_routing_type" {
  type    = string
  default = null
  validation {
    condition     = var.traffic_routing_type == null || var.traffic_routing_type == "TimeBasedLinear" || var.traffic_routing_type == "TimeBasedCanary"
    error_message = "The type should be TimeBasedLinear or TimeBasedCanary."
  }
}

# ========== Deployment fields ==========
