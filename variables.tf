variable "config" {
  type = object({
    filename              = optional(string, null),
    function_name         = string
    description           = optional(string, "created by a lambda builder"),
    timeout               = optional(number, 10),
    memory_size           = optional(number, 128),
    handler               = optional(string, "index.handler"),
    layers                = optional(list(string), null),
    runtime               = optional(string, "nodejs22.x"),
    environment_variables = optional(map(string), null),
    architecture          = optional(string, "arm64"),
    role_arn              = optional(string, null),
    ephemeral_storage     = optional(number, 512),
    publish               = optional(bool, false),
    force_deploy          = optional(bool, false),
    role_policy           = optional(string, null),
    tags                  = optional(map(string), null),
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

  validation {
    condition     = var.config.architecture == "arm64" || var.config.architecture == "x86_64"
    error_message = "Architecture should be either arm64 or x86_64."
  }
}

variable "vpc_config" {
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
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
    retention_in_days = 7,
  }
}

variable "docker_config" {
  type = object({
    create_repository    = optional(bool, false)
    repository_url       = optional(string, null)
    dockerfile_path      = optional(string, null)
    image_tag_mutability = optional(string, "MUTABLE")
    platform             = optional(string, "arm64")
    os                   = optional(string, "linux")
    force_delete         = optional(bool, false)
  })
  default = null
}

variable "alias_config" {
  type = object({
    name                      = optional(string, "live")
    description               = optional(string, "alias for live version"),
    stable_version_weights    = optional(number, 1),
    stable_version            = optional(string, null),
    versions_to_keep          = optional(number, null),
    force_delete_old_versions = optional(bool, false)
  })
  default = null
}

variable "alarm_config" {
  type = object({
    type                                 = optional(string, "error_detection"),
    period                               = optional(number, 60),
    actions_enabled                      = optional(bool, true),
    datapoints_to_alarm                  = optional(number, 1),
    evaluation_periods                   = optional(number, 5),
    normal_deviation                     = optional(number, 2),
    name                                 = optional(string, null),
    treat_missing_data                   = optional(string, "breaching"),
    statistic                            = optional(string, "Sum"),
    comparison_operator                  = optional(string, "GreaterThanThreshold"),
    threshold                            = optional(number, 1),
    description                          = optional(string, null),
    ok_actions                           = optional(list(string), null),
    alarm_actions                        = optional(list(string), null),
    sns_topic_arn                        = string,
    priority                             = string,
    metric_name                          = optional(string, null),
    namespace                            = optional(string, "AWS/Lambda"),
    dimensions                           = optional(map(string), null),
    insuficient_data_actions             = optional(list(string), null),
    unit                                 = optional(string, "Count"),
    extended_statistic                   = optional(string, null),
    evaluate_low_sample_count_percentile = optional(string, null),
    threshold_metric_id                  = optional(string, null),
    metric_query = optional(list(object({
      id          = string
      expression  = string
      label       = string
      return_data = bool
      metric = object({
        metric_name = string
        namespace   = string
        dimensions  = optional(map(string), null)
        period      = optional(number, 60)
        stat        = optional(string, "Average")
        unit        = optional(string, null)
      })
    })), null)
  })

  validation {
    condition     = try(var.alarm_config.priority == "P1" || var.alarm_config.priority == "P2", true)
    error_message = "The priority should be P1 or P2."
  }
  validation {
    condition     = try(var.alarm_config.type == "daily_check" || var.alarm_config.type == "error_detection" || var.alarm_config.type == "anomaly_detection" || var.alarm_config.type == "custom", true)
    error_message = "The values should be error_detection or anomaly_detection or custom"
  }

  validation {
    condition     = try(var.alarm_config.treat_missing_data == "missing" || var.alarm_config.treat_missing_data == "notBreaching" || var.alarm_config.treat_missing_data == "breaching" || var.alarm_config.treat_missing_data == "ignore", true)
    error_message = "The values should be missing, notBreaching or breaching."
  }

  default = null
}

variable "s3_source_config" {
  type = object({
    bucket         = string
    key            = string
    object_version = optional(string)
  })
  default = null
}

variable "s3_target_config" {
  type = object({
    targets = list(string)
  })
  default = null
}

variable "cron_config" {
  type = object({
    enabled         = optional(string, "ENABLED")
    input           = string
    cron_expression = string
  })
  default = null
}

variable "sqs_event_trigger" {
  type = object({
    sqs_arn                            = string,
    enabled                            = optional(bool, true),
    batch_size                         = optional(number, 10),
    filter_criteria_pattern            = optional(string, null),
    maximum_batching_window_in_seconds = optional(number, 20),
    function_response_types            = optional(list(string), null),
    maximum_concurrency                = optional(number, 2),
  })
  default = null
}

variable "sqs_target_config" {
  type = object({
    targets = list(string)
  })
  default = null
}

variable "sns_event_config" {
  type = object({
    topic_arn = string,
  })
  default = null
}

variable "kinesis_event_trigger" {
  type = object({
    kinesis_arn                        = string,
    enabled                            = optional(bool, true),
    batch_size                         = optional(number, 500),
    bisect_batch_on_function_error     = optional(bool, false),
    on_failure_destination_sqs_arn     = optional(string, null),
    maximum_record_age_in_seconds      = optional(number, 604800),
    maximum_retry_attempts             = optional(number, 2),
    starting_position                  = optional(string, "LATEST"),
    maximum_batching_window_in_seconds = optional(number, 0),
    parallelization_factor             = optional(number, 1),
    function_response_types            = optional(list(string), null),
    starting_position_timestamp        = optional(string, null),
    tumbling_window_in_seconds         = optional(number, 0),
    filter_criteria_pattern            = optional(string, null),
  })
  default = null
}

variable "kinesis_target_config" {
  type = object({
    targets = list(string)
  })
  default = null
}

variable "msk_event_trigger" {
  type = object({
    cluster_arn       = string,
    topic             = string,
    enabled           = optional(bool, true),
    batch_size        = optional(number, 500),
    starting_position = optional(string, "LATEST"),
  })
  default = null
}

variable "msk_target_config" {
  type = object({
    targets = list(string)
  })
  default = null
}

variable "s3_event_trigger" {
  type = object(
    {
      bucket_name   = string
      events        = list(string)
      filter_prefix = optional(string, null)
      filter_suffix = optional(string, null)
    }
  )
  default = null
}

variable "dynamo_event_trigger" {
  type = object({
    dynamo_stream_arn                  = string,
    enabled                            = optional(bool, true),
    batch_size                         = optional(number, 500),
    bisect_batch_on_function_error     = optional(bool, false),
    on_failure_destination_sqs_arn     = optional(string, null),
    maximum_record_age_in_seconds      = optional(number, 604800),
    maximum_retry_attempts             = optional(number, 2),
    starting_position                  = optional(string, "LATEST"),
    maximum_batching_window_in_seconds = optional(number, 0),
    parallelization_factor             = optional(number, 1),
    function_response_types            = optional(list(string), null),
    starting_position_timestamp        = optional(string, null),
    tumbling_window_in_seconds         = optional(number, 0),
    filter_criteria_pattern            = optional(string, null),
    filter_criteria_patterns           = optional(list(string), null),
  })
  default = null
  validation {
    condition     = try(var.dynamo_event_trigger.filter_criteria_pattern, null) == null
    error_message = <<ERR
      Filter `filter_criteria_pattern` has been changed to `filter_criteria_patterns`.
      Type changed to list(string) to support multiple patterns
    ERR
  }
}

variable "dynamo_target_config" {
  type = object({
    targets = list(string)
  })
  default = null
}

variable "api_event_trigger" {
  type = object({
    api_id        = string
    http_method   = string
    stage         = string
    resource_path = string
  })
  default = null
}

variable "appsync_event_trigger" {
  type = object({
    api_id = string
  })
  default = null
}

variable "lambda_target_config" {
  type = object({
    targets = list(string)
  })
  default = null
}

variable "step_function_target_config" {
  type = object({
    targets = list(string)
  })
  default = null
}

variable "firehose_target_config" {
  type = object({
    targets = list(string)
  })
  default = null
}
