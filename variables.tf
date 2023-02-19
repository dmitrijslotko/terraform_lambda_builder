variable "config" {
  type = object({
    filename              = string
    function_name         = string
    description           = optional(string, "created by a lambda builder"),
    timeout               = optional(number, 30),
    memory_size           = optional(number, 128),
    handler               = optional(string, "index.handler"),
    layers                = optional(list(string), null),
    runtime               = optional(string, "nodejs18.x"),
    environment_variables = optional(map(string), null),
    arhitecture           = optional(string, "arm64"),
    role_arn              = optional(string, null),
    ephemeral_storage     = optional(number, 512),
    publish               = optional(bool, false),
  })

  validation {
    condition     = length(var.config.function_name) <= 64
    error_message = "The name of the Lambda function, up to 64 characters in length."
  }

  validation {
    condition     = var.config.ephemeral_storage >= 512 || var.config.ephemeral_storage <= 10240
    error_message = "Lambda's ephemeral storage should be between 512 and 10240."
  }

  validation {
    condition     = var.config.timeout >= 1 && var.config.timeout <= 900
    error_message = "Timeout should be between 1 and 900."
  }

  validation {
    condition     = var.config.memory_size >= 128 && var.config.memory_size <= 10240
    error_message = "Memory size should be between 128 and 10240."
  }
}

variable "efs_config" {
  type = object({
    name               = optional(string, null)
    mount_path         = optional(string, "/mnt/efs")
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "log_group_config" {
  type = object({
    retention_in_days = number,
  })
  default = {
    retention_in_days = 30,
  }
}

variable "vpc_config" {
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "alias_config" {
  type = object({
    name                   = string
    description            = optional(string, null),
    stable_version_weights = optional(number, 1),
    stable_version         = optional(string, null),
    versions_to_keep       = optional(number, 5),
  })
  default = null
}

variable "alarm_config" {
  type = object({
    period              = optional(number, 60),
    sns_topic           = optional(string, null),
    actions_enabled     = optional(bool, true),
    datapoints_to_alarm = optional(number, 1),
    evaluation_periods  = optional(number, 5),
    normal_deviation    = optional(number, 2),
    name                = optional(string, null),
    type                = optional(string, "error_detection"),
    treat_missing_data  = optional(string, "breaching"),
    statistic           = optional(string, "Sum"),
    comparison_operator = optional(string, "GreaterThanOrEqualToThreshold"),
    threshold           = optional(number, 1),
    description         = optional(string, null),
    ok_actions          = optional(list(string), null),
    alarm_actions       = optional(list(string), null),
    priority            = optional(string, "P2")
  })
  default = null

  # validation {
  #   condition     = var.alarm_config.priority == "P1" || var.alarm_config.priority == "P2"
  #   error_message = "The priority should be P1 or P2."
  # }
  # validation {
  #   condition     = var.alarm_config.type == "error_detection" || var.alarm_config.type == "anomaly_detection"
  #   error_message = "The values should be error_detection or anomaly_detection."
  # }

  # validation {
  #   condition     = var.alarm_config.treat_missing_data == "missing" || var.alarm_config.treat_missing_data == "notBreaching" || var.alarm_config.treat_missing_data == "breaching"
  #   error_message = "The values should be missing, notBreaching or breaching."
  # }
}

variable "appsync_event_trigger" {
  type = object({
    enabled = optional(bool, true),
    api_id  = string,
    field   = string,
    type    = string
  })
  default = null
}


variable "api_gateway_trigger" {
  type = object({
    enabled     = optional(bool, true),
    rest_api_id = string,
    stage_name  = string,
    method      = string,
    path        = string
  })
  default = null
}

variable "s3_event_trigger" {
  type = object({
    bucket_name = string,
    events      = list(string),
    filter = optional(object({
      prefix = optional(string, null),
      suffix = optional(string, null)
    }), null)
  })
  default = null
}

variable "sqs_event_trigger" {
  type = object({
    enabled            = optional(bool, true),
    batch_size         = optional(number, 10),
    maximum_batching_w = optional(number, 10000),
    maximum_record_age = optional(number, 604800),
    maximum_retry      = optional(number, 10000),
    bisect_batch_on_f  = optional(bool, false),
    destination_config = optional(object({
      on_success = optional(object({
        destination = string
      }), null)
      on_failure = optional(object({
        destination = string
      }), null)
    }), null)
  })
  default = null
}

variable "dynamo_event_trigger" {
  type = object({
    dynamodb_stream_arn = string,
    batch_size          = optional(number, 100),
    enabled             = optional(bool, true),
    starting_position   = optional(string, "LATEST"),
    parallelization     = optional(number, 1),
    maximum_batching_w  = optional(number, 10000),
    maximum_record_age  = optional(number, 604800),
    maximum_retry       = optional(number, 10000),
    bisect_batch_on_f   = optional(bool, false),
    destination_config = optional(object({
      on_success = optional(object({
        destination = string
      }), null)
      on_failure = optional(object({
        destination = string
      }), null)
    }), null)
  })
  default = null

  # validation {
  #   condition     = var.dynamo_event_trigger.starting_position != "LATEST" || var.dynamo_event_trigger.starting_position != "TRIM_HORIZON"
  #   error_message = "Allowed values are LATEST or TRIM_HORIZON."
  # }
}

variable "kinesis_event_trigger" {
  type = object({
    kinesis_arn       = string,
    batch_size        = optional(number, 500),
    enabled           = optional(bool, true),
    starting_position = optional(string, "LATEST")
  })
  default = null

  # validation {
  #   condition     = var.kinesis_event_trigger != null && var.kinesis_event_trigger.starting_position != "LATEST" || var.kinesis_event_trigger.starting_position != "TRIM_HORIZON" || var.kinesis_event_trigger.starting_position != "AT_TIMESTAMP"
  #   error_message = "Allowed values are LATEST, TRIM_HORIZON or AT_TIMESTAMP."
  # }
}

variable "cron_config" {
  type = object({
    enabled         = optional(bool, true)
    input           = string
    cron_expression = string
  })
  default = null
}

variable "s3_source_config" {
  type = object({
    bucket  = string
    key     = string
    version = optional(string)
  })
  default = null
}

