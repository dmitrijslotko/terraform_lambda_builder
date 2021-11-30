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

variable "create_lambda_role" {
  type    = bool
  default = false
}

variable "lambda_runtime" {
  type    = string
  default = "nodejs14.x"
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

variable "lambda_role" {
  type    = string
  default = null
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

# ========== Image lambda fields ==========




