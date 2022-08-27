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

# ALARM FIELDS
variable "add_alarm" {
  type    = bool
  default = false
}

variable "sns_topic" {
  type    = string
  default = null
}

variable "actions_enabled" {
  type    = bool
  default = true
}

variable "datapoints_to_alarm" {
  type    = number
  default = 1
}

variable "evaluation_periods" {
  type    = number
  default = 5
}

variable "period" {
  type    = number
  default = 60
}

variable "normal_deviation" {
  type    = number
  default = 2
}

variable "alarm_type" {
  type    = string
  default = "error_detection"
  validation {
    condition     = var.alarm_type == "error_detection" || var.alarm_type == "anomaly_detection"
    error_message = "The values should be error_detection or anomaly_detection."
  }
}

variable "treat_missing_data" {
  type    = string
  default = "notBreaching"
  validation {
    condition     = var.treat_missing_data == "notBreaching" || var.treat_missing_data == "breaching"
    error_message = "The values should be breaching or notBreaching."
  }
}

variable "alarm_priority" {
  type    = string
  default = "P2"
  validation {
    condition     = var.alarm_priority == "P1" || var.alarm_priority == "P2"
    error_message = "The priority should be P1 or P2."
  }
}
# ALARM FIELDS

# OPTIONAL FIELDS
variable "handler" {
  type    = string
  default = "index.handler"
}

variable "role_arn" {
  type    = string
  default = ""
}

variable "runtime" {
  type    = string
  default = "nodejs16.x"
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

# LAMBDA PERMISSIONS

variable "appsync_source_arn" {
  type    = string
  default = null
}

variable "api_gw_source_arn" {
  type    = string
  default = null
}

variable "s3_notification_bucket_name" {
  type    = string
  default = null
}

variable "s3_notification_events" {
  type    = list(string)
  default = null
}

variable "s3_notification_filter_prefix" {
  type    = string
  default = null
}

variable "s3_notification_filter_suffix" {
  type    = string
  default = null
}

variable "sqs_source_arn" {
  type    = string
  default = null
}

# LAMBDA PERMISSIONS

# EVENT SOURCE MAPPINGS

variable "dynamodb_stream_arn" {
  type    = string
  default = null
}

variable "dynamodb_stream_starting_position" {
  type    = string
  default = "LATEST"
  validation {
    condition     = var.dynamodb_stream_starting_position != "LATEST" || var.dynamodb_stream_starting_position != "TRIM_HORIZON"
    error_message = "Allowed values are LATEST or TRIM_HORIZON."
  }
}

variable "kinesis_stream_arn" {
  type    = string
  default = null
}

variable "kinesis_stream_starting_position" {
  type    = string
  default = "LATEST"
  validation {
    condition     = var.kinesis_stream_starting_position != "LATEST" || var.kinesis_stream_starting_position != "TRIM_HORIZON" || var.kinesis_stream_starting_position != "AT_TIMESTAMP"
    error_message = "Allowed values are LATEST, TRIM_HORIZON or AT_TIMESTAMP."
  }
}

# EVENT SOURCE MAPPINGS


# CW EVENT RULE

variable "cw_event_input" {
  type    = string
  default = null
}

variable "cw_event_is_enabled" {
  type    = bool
  default = true
}

variable "cw_event_cron_expression" {
  type    = string
  default = null
}
# CW EVENT RULE
