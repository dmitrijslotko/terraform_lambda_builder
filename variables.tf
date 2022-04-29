# MANDATORY FIELDS

variable "filename" {
  type = string
}

variable "function_name" {
  type = string
  validation {
    condition     = length(var.function_name) <= 64
    error_message = "The name of the Lambda function, up to 64 characters in length."
  }
}
# MANDATORY FIELDS


# OPTIONAL FIELDS
variable "handler" {
  type    = string
  default = "index.handler"
}

variable "runtime" {
  type    = string
  default = "nodejs14.x"
}
variable "lambda_retention_in_days" {
  type    = number
  default = 30
}
variable "timeout" {
  type    = number
  default = 30
  validation {
    condition     = var.timeout <= 900
    error_message = "Lambda timeout variable cannot be more than 900 seconds (15 minutes)."
  }
}
variable "layers" {
  type        = list(string)
  default     = null
  description = "expects to receive a list of layer arns"
}

variable "memory_size" {
  type    = number
  default = 256
  validation {
    condition     = var.memory_size >= 256 || var.memory_size <= 10240
    error_message = "Lambda's memory should be between 256 and 10240."
  }
}

variable "ephemeral_storage" {
  type    = number
  default = 512
  validation {
    condition     = var.ephemeral_storage >= 512 || var.ephemeral_storage <= 10240
    error_message = "Lambda's ephemeral storage should be between 512 and 10240."
  }
}

variable "environment_variables" {
  type    = map(string)
  default = null
}

# OPTIONAL FIELDS


# VPC FIELDS
variable "subnet_ids" {
  type    = list(string)
  default = null
}

variable "security_group_ids" {
  type    = list(string)
  default = null
}

# VPC FIELDS

# EFS FIELD
variable "add_efs" {
  type    = bool
  default = false
}

# EFS FIELD

# ALIAS FIELDS
variable "alias" {
  type    = string
  default = null
}

variable "stable_version_weights" {
  type    = number
  default = 1
  validation {
    condition     = var.stable_version_weights >= 0 && var.stable_version_weights <= 1
    error_message = "Weight should be between 0 and 1."
  }
}

variable "stable_version" {
  type    = number
  default = null
}

variable "versions_to_keep" {
  type    = number
  default = null
}

# ALIAS FIELDS
