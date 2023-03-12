## Main Config

The `config` block in this Terraform configuration defines an object schema with various optional and required properties to deploy a Lambda function.

`filename` (string, required) - This refers to the location where the code for the function is stored, including any dependencies needed by the function to execute.
`function_name` (string, required) - The name of the Lambda function.

`description` (string, optional, default: "created by a lambda builder") - A description of the Lambda function.
`timeout` (number, optional, default: 30) - The maximum amount of time that the Lambda function can run before it is terminated.
`memory_size` (number, optional, default: 128) - The amount of memory that the Lambda function is allocated.
`handler` (string, optional, default: "index.handler") - The name of the file and function (file name is "index.js", function name is "handler") within your code that Lambda calls to start execution.
`layers` (list(string), optional, default: null) - The ARNs of any layers to attach to the function.
`layer_prefix` (string, optional, default: "/opt/nodejs/") - If a layer is attached, the environment variables will have the prefix added to them.
`runtime` (string, optional, default: "nodejs18.x") - The runtime environment for the Lambda function.
`environment_variables` (map(string), optional, default: null) - A map of environment variables to pass to the function.
`architecture` (string, optional, default: "arm64") - The architecture of the function's runtime environment.
`role_arn` (string, optional, default: null) - The ARN of the IAM role that the function assumes when it executes.
`ephemeral_storage` (number, optional, default: 512) - The amount of ephemeral storage that the function can use.
`publish` (bool, optional, default: false) - Whether to publish a new version of the function after it is created.
`force_deploy` (bool, optional, default: false) - Whether to force a deployment of the function even if there are no changes to the configuration.

## Example

```hcl
   root_directory/
   |── src/
      |── lambda_code/
         |── index.js
```

```hcl
module "lambda_function" {
  # ... other variables ...

  config = {
    filename        = "./src/lambda_code"
    function_name   = "my-lambda-function"
    description     = "Created by a lambda builder module"
    timeout         = 300
    memory_size     = 512
    layers          = ["arn:aws:lambda:us-west-2:111111111111:layer:my-layer:1"]
    environment_variables = {
      VAR1 = "value1"
      VAR2 = "value2"
    }
    ephemeral_storage = 1024
    publish         = true
  }
}
```

## VPC_CONFIG

This configuration is used to specify the networking resources that the Lambda function will be attached to, allowing it to communicate with other resources within the VPC.

`subnet_ids` (list(string), required): A list of IDs of the subnets in which to create the Lambda function's network interfaces.
`security_group_ids` (list(string), required): A list of IDs of the security groups to associate with the Lambda function's network interfaces.

## Example

```hcl
module "lambda_function" {
  # ... other variables ...

  vpc_config = {
    subnet_ids = [
      "subnet-123456",
      "subnet-789012",
    ]
    security_group_ids = [
      "sg-123456",
    ]
  }
}
```

## EFS_CONFIG

This configuration is used to specify the Amazon EFS resources that the Lambda function will be attached to, allowing it to read and write data to the file system.

`subnet_ids` (list(string), required): The IDs of the subnets in which to create the EFS mount targets. Lambda should be deployed in the same subnets.
`security_group_ids` (list(string), required): The IDs of the security groups to associate with the EFS mount targets.

`name` (string, optional): The name of the EFS file system. If not specified, Terraform will generate a unique name.
`mount_path` (string, optional): The local mount path for the EFS file system. Defaults to /mnt/efs.

## Example

```hcl
module "lambda_function" {
  # ... other variables ...

  vpc_config = {
    subnet_ids = [
      "subnet-123456",
      "subnet-789012",
    ]
    security_group_ids = [
      "sg-123456",
    ]
  }

  efs_config = {
    subnet_ids = [
      "subnet-123456",
      "subnet-789012",
    ]
    security_group_ids = [
      "sg-123456",
    ]
  }
}
```

## LOG_GROUP_CONFIG

This configuration is used to specify the retention policy for the CloudWatch Logs group that the Lambda function will be attached to, allowing you to set how long the logs are retained.
The default attribute is set to an object with a single property retention_in_days that has a default value of 30. This means that if the log_group_config variable is not set in the Terraform configuration, it will default to retaining logs for 30 days.
If the `log_group_config` object is set to `null`, the log group will not be created.

`retention_in_days` (number, required): The number of days to retain the logs in the log group before they expire. Must be a positive integer.

The `retention_in_days` property of the `log_group_config` object has a default value of 30 days.

## Example

```hcl
module "lambda_function" {
  # ... other variables ...

  log_group_config = {
    retention_in_days = 7
  }
}
```

## ALIAS_CONFIG

AWS Lambda functions can use aliases to create a logical reference to a specific version of the function. An alias is a named resource that is not a function version, but instead points to a specific function version.
By using aliases, you can decouple your Lambda function versioning and deployment strategies from your application logic, making it easier to manage and update your functions over time.

`name`: (string, Optional) The name of the alias. Default is `live`.
`description`: (string, Optional) The description of the alias. Default is `alias for live version`.
`stable_version_weights`: (number, Optional) The weight of the stable version. Default is `1`.
`stable_version`: (string, Optional) The version of the Lambda function that the alias points to.
`versions_to_keep`: (number, Optional) The number of versions to keep when updating the alias. Default is null.
`force_delete_old_versions`: (bool, Optional) Whether to delete old versions of the Lambda function when updating the alias. Default is false.

## Example

```hcl
module "lambda_function" {
  # ... other variables ...

  alias_config = {
    stable_version = "7"
    stable_version_weights = 0.9
    versions_to_keep = 3
  }
}
```

## ALARM_CONFIG

To use CloudWatch alarms with Lambda functions, you can create a CloudWatch alarm and configure it to monitor the appropriate metrics for your Lambda function. You can then configure the alarm to trigger an action, such as sending an email notification or invoking a Lambda function, when the threshold is exceeded.

`type` (optional, string): The type of alarm. Can be "daily_check", "error_detection", "anomaly_detection", or "custom". Defaults to "error_detection".
`period`: (optional) The period in seconds over which the specified statistic is applied. Defaults to 60.
`actions_enabled`: (optional) Indicates whether actions should be executed during any changes to the alarm's state. Defaults to true.
`datapoints_to_alarm`: (optional) The number of data points that must be breaching to trigger the alarm. Defaults to 1.
`evaluation_periods`: (optional) The number of periods over which data is compared to the specified threshold. Defaults to 5.
`normal_deviation`: (optional) The number of standard deviations to use for the upper and lower bounds of the anomaly detection band. Defaults to 2.
`name`: (optional) The name for the alarm. If not provided, a default name will be used.
`treat_missing_data`: (optional) Sets how missing data points are treated. Defaults to breaching.
`statistic`: (optional) The statistic to apply to the alarm's associated metric. Defaults to Sum.
`comparison_operator`: (optional) The comparison operator to use when comparing the specified statistic and threshold. Defaults to GreaterThanThreshold.
`threshold`: (optional) The value against which the specified statistic is compared. Defaults to 1.
`description`: (optional) The description for the alarm. If not provided, no description will be set.
`ok_actions`: (optional) The list of actions to execute when the alarm transitions to the OK state.
`alarm_actions`: (optional) The list of actions to execute when the alarm transitions to the ALARM state.
`sns_topic_arn`: (optional) The ARN of the SNS topic to notify when the alarm changes state.
`priority`: (optional) The priority of the alarm. Defaults to P2.
`metric_name`: (optional) The name of the metric associated with the alarm. If not provided, a default name will be used.
`namespace`: (optional) The namespace of the metric associated with the alarm. Defaults to AWS/Lambda.
`dimensions`: (optional) The dimensions associated with the alarm's metric. If not provided, no dimensions will be set.
`insuficient_data_actions`: (optional) The list of actions to execute when the alarm transitions to the INSUFFICIENT_DATA state.
`unit` (optional, string): The unit of the metric being monitored. Defaults to "Count".
`extended_statistic` (optional, string): The extended statistic being used for the alarm.
`evaluate_low_sample_count_percentile` (optional, string): The percentile being used for the alarm evaluation.
`threshold_metric_id` (optional, string): The metric ID for the threshold.
`metric_query` (optional, list of objects): A list of metric queries to use for the alarm. Each query contains the following attributes:

`id` (string): A unique identifier for the metric query.
`expression` (string): The metric query expression.
`label` (string): The label for the metric.
`return_data` (bool): Whether or not to return the metric data.
`metric` (object): The metric being queried. Contains the following attributes:

`metric_name`: The name of the metric.
`namespace`: The namespace of the metric.
`dimensions` (optional): A map of key-value pairs that define the dimensions of the metric.
`period` (optional): The granularity, in seconds, of the metric data points.
`stat` (optional): The statistic to apply to the metric. Valid values are "SampleCount", "Average", "Sum", "Minimum", "Maximum".
`unit` (optional): The unit of the metric.

## Usage

## Example 1

```hcl
module "lambda_function" {
  # ... other variables ...

  alarm_config = {
    type          = "error_detection"
    sns_topic_arn = "arn:aws:sns:us-west-2:111111111111:topic"
  }
}
```

## Example 2

```hcl
module "lambda_function" {
  # ... other variables ...

  alarm_config = {
    type          = "daily_check"
    ok_actions = ["arn:aws:sns:us-west-2:111111111111:ok_topic"]
    alarm_actions = ["arn:aws:sns:us-west-2:111111111111:alarm_topic"]
  }
}
```

## S3_SOURCE_COFIG

The `s3_source_config` object is used to specify the S3 bucket and object key for the source code of the Lambda function.

The object has the following attributes:

`bucket` (required): The name of the S3 bucket where the source code is located.
`key` (required): The object key of the source code file in the S3 bucket.
`object_version` (optional): The version of the S3 object to use. If not specified, the latest version is used.

## Example

```hcl
   root_directory/
   |── src/
      |── .build/
         |── lambda.zip
```

```hcl
module "lambda_function" {
  # ... other variables ...

  s3_source_config = {
    bucket = "bucket-name"
    key    = ".src/.build/lambda.zip"
  }
}
```

## CRON_CONFIG

This variable is typically used to configure a scheduled Lambda function that is triggered based on a cron expression. The input field specifies the input that will be passed to the Lambda function when it is triggered. The cron_expression field specifies the cron expression that defines when the Lambda function will be triggered.

If enabled is set to false, the cron job will not be created or updated by Terraform. If enabled is not specified, it defaults to true. The default value of null for the default argument means that if the variable is not set, it will have no value.

`cron_expression` (string, required): The cron expression that specifies when to execute the Lambda function.

`enabled` (optional bool, default is true): Indicates whether the cron job is enabled or not.
`input` (string): The input to be passed to the Lambda function.

## Example

```hcl
module "lambda_function" {
  # ... other variables ...

  cron_config = {
    cron_expression = "cron(* * * * ? *)"
    input = jsonencode({
      "key1" = "value1"
      "key2" = "value2"
    })
  }
}
```

## SQS_EVENT_TRIGGER

Lambda can be triggered by a variety of event sources, including Amazon Simple Queue Service (SQS) queues. When a message is added to an SQS queue, a Lambda function can be automatically triggered to process the message.
Additionally, you will need to create the SQS queue separately and specify its ARN in the sqs_arn property.

`sqs_arn`: A required string that specifies the ARN of the Amazon Simple Queue Service (SQS) queue to use as the event source for the Lambda function.

`enabled`: An optional boolean that specifies whether the event source mapping is enabled. The default value is true.
`batch_size`: An optional number that specifies the maximum number of messages to retrieve from the SQS queue in each batch. The default value is 10.
`filter_criteria_pattern`: An optional string that specifies a pattern to filter the messages retrieved from the SQS queue. The default value is null.
`maximum_batching_window_in_seconds`: An optional number that specifies the maximum amount of time to wait before invoking the Lambda function with a batch of messages. The default value is 20.
`function_response_types`: A list of current response type enums applied to the event source mapping for AWS Lambda checkpointing. Valid value is `ReportBatchItemFailures`. Default value is `null`
`scaling_config`: An optional string that specifies the configuration for scaling the number of concurrent executions of the Lambda function. The default value is null.

## Example

```hcl
module "lambda_function" {
  # ... other variables ...

  sqs_event_trigger = {
    sqs_arn = "arn:aws:sqs:us-west-2:111111111111:dlq"
  }
}
```

## SNS_EVENT_TRIGGER

Lambda can be triggered by a variety of event sources, including Amazon Simple Notification Service (SNS). When a message is added to an SNS topic, a Lambda function can be automatically triggered to process the message.
Additionally, you will need to create the SNS topic separately and specify its ARN in the `topic_arn` property.

`topic_arn`: A required string that specifies the Amazon Resource Name (ARN) of the Amazon SNS topic to use as the event source for the Lambda function.

## Example

```hcl
module "lambda_function" {
  # ... other variables ...

  sns_event_config = {
    topic_arn = "arn:aws:sns:us-west-2:111111111111:topic_name"
  }
}
```

## KINESIS_EVENT_TRIGGER

A Lambda function can use Kinesis as an event trigger to process streaming data in real-time. When new data is added to a Kinesis stream, the event trigger invokes the Lambda function, which can then process the data and take appropriate actions.

`kinesis_arn`: A required string that specifies the Amazon Resource Name (ARN) of the Amazon Kinesis stream to use as the event source for the Lambda function.

`enabled`: An optional boolean value that indicates whether the event source mapping is enabled. If false, the event source mapping is not created or updated.
`batch_size`: An optional number that specifies the maximum number of records to read from the Kinesis stream in each batch.
`bisect_batch_on_function_error`: An optional boolean value that indicates whether to split the batch into smaller batches if the function returns an error.
`on_failure_destination_sqs_arn`: An optional string that specifies the Amazon Resource Name (ARN) of the SQS queue to send failed events to.
`maximum_record_age_in_seconds`: An optional number that specifies the maximum age of a record in the Kinesis stream before it is discarded.
`maximum_retry_attempts`: An optional number that specifies the maximum number of times to retry a failed batch of events.
`starting_position`: An optional string that specifies the starting position in the stream. Valid values are "TRIM_HORIZON" (oldest available record), "LATEST" (most recent record), or a timestamp.
`maximum_batching_window_in_seconds`: An optional number that specifies the maximum amount of time to wait before invoking the function with a batch of events.
`parallelization_factor`: An optional number that specifies the number of batches to process concurrently.
`function_response_types`: An optional list of strings that specifies the types of responses to include in the function's invocation results.
`starting_position_timestamp`: An optional string that specifies the timestamp of the record to start reading from.
`tumbling_window_in_seconds`: An optional number that specifies the duration of the tumbling window (the time period during which records are grouped for processing).
`filter_criteria_pattern`: An optional string that specifies a pattern used to filter the records in the stream.

## Example

```hcl
module "lambda_function" {
  # ... other variables ...

  kinesis_event_trigger = {
    kinesis_arn = "arn:aws:kinesis:us-west-2:111111111111:stream_name"
  }
}
```

## S3_EVENT_TRIGGER

By using S3 as an event trigger for Lambda, you can process the object data immediately after it is created or deleted, enabling real-time data processing workflows.

`bucket_name`: A required string that specifies the name of the S3 bucket to use as the event source for the Lambda function.
`events`: A required list of strings that specifies the types of S3 events that will trigger the Lambda function.
`filter_prefix`: An optional string that specifies a prefix filter for the S3 event notifications.
`filter_suffix`: An optional string that specifies a suffix filter for the S3 event notifications.

Note: one one combination of event and filter_prefix can exists.

## Example

```hcl
module "lambda_function" {
  # ... other variables ...

  s3_event_trigger = {
    bucket_name   = "bucket-name"
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "images/"
  }
}
```

## DYNAMO_EVENT_TRIGGER

By using DynamoDB streams as an event source for Lambda, you can process changes to the DynamoDB table data immediately as they occur, enabling real-time data processing workflows.

`dynamo_stream_arn`: A required string that specifies the ARN of the DynamoDB Stream to use as the event source for the Lambda function.

`enabled`: An optional boolean that indicates whether the event source mapping is enabled. The default value is true.
`batch_size`: An optional number that specifies the maximum number of stream records that will be sent to the Lambda function in a single batch. The default value is 500.
`bisect_batch_on_function_error`: An optional boolean that indicates whether to split a batch when one or more records in the batch result in a function error. The default value is false.
`on_failure_destination_sqs_arn`: An optional string that specifies the ARN of the SQS queue to which to send events that could not be processed. The default value is null.
`maximum_record_age_in_seconds`: An optional number that specifies the maximum age of a record in the stream in seconds. The default value is 604800 (7 days).
`maximum_retry_attempts`: An optional number that specifies the maximum number of times to retry a failed invocation. The default value is 2.
`starting_position`: An optional string that specifies the position in the stream where the function should start processing events. The default value is "LATEST".
`maximum_batching_window_in_seconds`: An optional number that specifies the maximum amount of time to gather records before invoking the function. The default value is 0.
`parallelization_factor`: An optional number that specifies the number of batches to process in parallel. The default value is 1.
`function_response_types`: An optional list of strings that specifies the types of function responses to include in the event. The default value is null.
`starting_position_timestamp`: An optional string that specifies the timestamp in ISO 8601 format where the function should start processing events. The default value is null.
`tumbling_window_in_seconds`: An optional number that specifies the size of the tumbling window in seconds. The default value is 0.
`filter_criteria_pattern`: An optional string that specifies a filter pattern for the stream records. The default value is null.

## Example 1

```hcl
module "lambda_function" {
  # ... other variables ...

  dynamo_event_trigger = {
    dynamo_stream_arn = "arn:aws:dynamodb:us-west-2:111111111111:table/table_name/stream/date"
  }
}
```

## Example 2

```hcl
module "lambda_function" {
  # ... other variables ...

  dynamo_event_trigger = {
     dynamo_stream_arn = "arn:aws:dynamodb:us-west-2:111111111111:table/table_name/stream/date"
    filter_criteria_pattern = jsonencode({
      "eventName" : [
        "REMOVE"
      ]
    })
  }
}
```

## API_EVENT_TRIGGER

Lambda can use Amazon API Gateway as an event source

`api_id`: The ID of the API Gateway REST API that should trigger the Lambda function.
`http_method`: The HTTP method (e.g., GET, POST, PUT, DELETE) that should trigger the Lambda function.
`stage`: The name of the API Gateway stage that should trigger the Lambda function.
`resource_path`: The resource path of the API Gateway resource that should trigger the Lambda function.

```hcl
module "lambda_function" {
  # ... other variables ...

  api_event_trigger = {
    api_id        = "ts23cpnlec"
    resource_path = "test"
    http_method   = "get"
    stage         = "dev"
  }
}
```
