# Lambda Builder

# Table of Contents

1. [Config](#config)
2. [VPC_CONFIG](#vpc_config)
3. [EFS_CONFIG](#efs_config)
4. [LOG_GROUP_CONFIG](#log_group_config)
5. [ALIAS_CONFIG](#alias_config)
6. [ALARM_CONFIG](#alarm_config)
7. [DOCKER_CONFIG](docker_config)
8. [S3_SOURCE_COFIG](#s3_source_config)
9. [CRON_CONFIG](#cron_config)
10. [SQS_EVENT_TRIGGER](#sqs_event_trigger)
11. [SQS_TARGET_CONFIG](#sqs_target_config)
12. [SNS_EVENT_TRIGGER](#sns_event_trigger)
13. [KINESIS_EVENT_TRIGGER](#kinesis_event_trigger)
14. [KINESIS_TARGET_CONFIG](#kinesis_target_config)
15. [S3_EVENT_TRIGGER](#s3_event_trigger)
16. [S3_TARGET_CONFIG](#s3_target_config)
17. [DYNAMO_EVENT_TRIGGER](#dynamo_event_trigger)
18. [DYNAMO_TARGET_CONFIG](#dynamo_target_config)
19. [API_EVENT_TRIGGER](#api_event_trigger)
20. [LAMBDA_TARGET_CONFIG](#lambda_target_config)
21. [STEP_FUNCTION_TARGET_CONFIG](#step_function_target_config)
22. [FIREHOSE_TARGET_CONFIG](#firehose_target_config)
23. [OUTPUTS](#outputs)

### CONFIG

The `config` block in this Terraform configuration defines an object schema with various optional and required properties to deploy a Lambda function.

- `architecture` (string, optional, default: "arm64") - The architecture of the function's runtime environment.
- `description` (string, optional, default: "created by a lambda builder") - A description of the Lambda function.
- `environment_variables` (map(string), optional, default: null) - A map of environment variables to pass to the function.
- `ephemeral_storage` (number, optional, default: 512) - The amount of ephemeral storage that the function can use.
- **`filename`** (string, required) - This refers to the location where the code for the function is stored, including any dependencies needed by the function to execute.
- `force_deploy` (bool, optional, default: false) - Whether to force a deployment of the function even if there are no changes to the configuration.
- **`function_name`** (string, required) - The name of the Lambda function.
- `handler` (string, optional, default: "index.handler") - The name of the file and function (file name is "index.py", function name is "handler") within your code that Lambda calls to start execution.
- `layers` (list(string), optional, default: null) - The ARNs of any layers to attach to the function.
- `memory_size` (number, optional, default: 128) - The amount of memory that the Lambda function is allocated.
- `publish` (bool, optional, default: false) - Whether to publish a new version of the function after it is created.
- `role_arn` (string, optional, default: null) - The ARN of the IAM role that the function assumes when it executes.
- `runtime` (string, optional, default: "python3.12") - The runtime environment for the Lambda function.
- `timeout` (number, optional, default: 30) - The maximum amount of time that the Lambda function can run before it is terminated.

### Example 1

To pull module using SSH key. Does not work with Gitlab pipeline.

```hcl
module "lambda_function" {
  source = "source = "github.com/dmitrijslotko/terraform_lambda_builder?ref=vX.X.X"

  # ... other variables ...
}
```

### Example 2

```
   root_directory/
   |── src/
      |── lambda_code/
         |── index.py
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

- **`security_group_ids`** (list(string), required): A list of IDs of the security groups to associate with the Lambda function's network interfaces.
- **`subnet_ids`** (list(string), required): A list of IDs of the subnets in which to create the Lambda function's network interfaces.

### Example

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

- `mount_path` (string, optional): The local mount path for the EFS file system. Defaults to /mnt/efs.
- `name` (string, optional): The name of the EFS file system. If not specified, Terraform will generate a unique name.
- **`security_group_ids`** (list(string), required): The IDs of the security groups to associate with the EFS mount targets.
- **`subnet_ids`** (list(string), required): The IDs of the subnets in which to create the EFS mount targets. Lambda should be deployed in the same subnets.

### Example

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

- **`retention_in_days`** (number, required): The number of days to retain the logs in the log group before they expire. Must be a positive integer.

The `retention_in_days` property of the `log_group_config` object has a default value of 30 days.

### Example

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

- `description`: (string, Optional) The description of the alias. Default is `alias for live version`.
- `force_delete_old_versions`: (bool, Optional) Whether to delete old versions of the Lambda function when updating the alias. Default is false.
- `name`: (string, Optional) The name of the alias. Default is `live`.
- `stable_version`: (string, Optional) The version of the Lambda function that the alias points to.
- `stable_version_weights`: (number, Optional) The weight of the stable version. Default is `1`.
- `versions_to_keep`: (number, Optional) The number of versions to keep when updating the alias. Default is null.

### Example

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

- `actions_enabled`: (optional) Indicates whether actions should be executed during any changes to the alarm's state. Defaults to true.
- `alarm_actions`: (optional) The list of actions to execute when the alarm transitions to the ALARM state.
- `comparison_operator`: (optional) The comparison operator to use when comparing the specified statistic and threshold. Defaults to GreaterThanThreshold.
- `datapoints_to_alarm`: (optional) The number of data points that must be breaching to trigger the alarm. Defaults to 1.
- `description`: (optional) The description for the alarm. If not provided, no description will be set.
- `dimensions`: (optional) The dimensions associated with the alarm's metric. If not provided, no dimensions will be set.
- `evaluate_low_sample_count_percentile` (optional, string): The percentile being used for the alarm evaluation.
- `evaluation_periods`: (optional) The number of periods over which data is compared to the specified threshold. Defaults to 5.
- `extended_statistic` (optional, string): The extended statistic being used for the alarm.
- `insuficient_data_actions`: (optional) The list of actions to execute when the alarm transitions to the INSUFFICIENT_DATA state.
- `metric_name`: (optional) The name of the metric associated with the alarm. If not provided, a default name will be used.
- `metric_query` (optional, list of objects): A list of metric queries to use for the alarm. Each query contains the following attributes:
  - **`expression`** (string): The metric query expression.
  - **`id`** (string): A unique identifier for the metric query.
  - **`label`** (string): The label for the metric.
  - **`metric`** (object): The metric being queried. Contains the following attributes:
  - `return_data` (bool): Whether or not to return the metric data.
    - `dimensions` (optional): A map of key-value pairs that define the dimensions of the metric.
    - **`metric_name`**: The name of the metric.
    - **`namespace`**: The namespace of the metric.
    - `period` (optional): The granularity, in seconds, of the metric data points.
    - `stat` (optional): The statistic to apply to the metric. Valid values are "SampleCount", "Average", "Sum", "Minimum", "Maximum".
    - `unit` (optional): The unit of the metric.
- `name`: (optional) The name for the alarm. If not provided, a default name will be used.
- `namespace`: (optional) The namespace of the metric associated with the alarm. Defaults to AWS/Lambda.
- `normal_deviation`: (optional) The number of standard deviations to use for the upper and lower bounds of the anomaly detection band. Defaults to 2.
- `ok_actions`: (optional) The list of actions to execute when the alarm transitions to the OK state.
- `period`: (optional) The period in seconds over which the specified statistic is applied. Defaults to 60.
- **`priority`**: (string) The priority of the alarm.
- **`sns_topic_arn`**: (string) The ARN of the SNS topic to notify when the alarm changes state.
- `statistic`: (optional) The statistic to apply to the alarm's associated metric. Defaults to Sum.
- `threshold`: (optional) The value against which the specified statistic is compared. Defaults to 1.
- `threshold_metric_id` (optional, string): The metric ID for the threshold.
- `treat_missing_data`: (optional) Sets how missing data points are treated. Defaults to breaching.
- **`type`** (optional, string): The type of alarm. Can be "daily_check", "error_detection", "anomaly_detection", or "custom". Defaults to "error_detection".
- `unit` (optional, string): The unit of the metric being monitored. Defaults to "Count".

## Usage

### Example 1

```hcl
module "lambda_function" {
  # ... other variables ...

  alarm_config = {
    type          = "error_detection"
    sns_topic_arn = "arn:aws:sns:us-west-2:111111111111:topic"
    priority      = "P2"
  }
}
```

## Example 2

```hcl
module "lambda_function" {
  # ... other variables ...

  alarm_config = {
    type          = "daily_check"
    ok_actions    = ["arn:aws:sns:us-west-2:111111111111:ok_topic"]
    alarm_actions = ["arn:aws:sns:us-west-2:111111111111:alarm_topic"]
    priority      = "P1"
  }
}
```

## DOCKER_CONFIG

The `docker_config` variable allows you to specify the Docker configuration for your Lambda function. It is an object type with the following optional fields:

- `repository_url` (optional, string): The URL of the Docker repository where the Lambda function's container image will be stored. If not provided, the Lambda function will use a local Docker image.
- **`dockerfile_path`** (required, string): The path to the Dockerfile used to build the Lambda function's container image. This path must be relative to the root of the Terraform module.
- `image_tag_mutability` (optional, string): The mutability of the image tag for the Lambda function's container image. The default value is "MUTABLE". Possible values are "MUTABLE" and "IMMUTABLE".
- `platform` (optional, string): The platform architecture for the Lambda function's container image. The default value is "arm64". Possible values: "arm64" and "x86_64". This field is used to specify the CPU architecture for the Docker image and the lambda function.
- `os` (optional, string): The operating system for the Lambda function's container image. The default value is "linux". This field is used to specify the operating system for the Docker image.

- **Note**: you must have instaled docker and laucnhed docker agent to be able to build images locally.

### Example

```hcl
   root_directory/
   |── src/
      |── lambda_code/
         |── index.py
         |── Dockerfile
         |── package.json
```

```hcl
module "lambda_function" {
  # ... other variables ...

  docker_config = {
    dockerfile_path = "./src/lambda_code/Dockerfile"
  }
}
```

example of the Dockerfile

```hcl
# Use the AWS provided Node.js 18 base image
FROM public.ecr.aws/lambda/nodejs:18

COPY index.js ${LAMBDA_TASK_ROOT}
COPY package.json ${LAMBDA_TASK_ROOT}

RUN npm i

# Set the CMD to your handler (app.handler) which is the entry point for your function
CMD ["index.handler"]
```

## S3_SOURCE_COFIG

The `s3_source_config` object is used to specify the S3 bucket and object key for the source code of the Lambda function.

The object has the following attributes:

- **`bucket`** (required): The name of the S3 bucket where the source code is located.
- **`key`** (required): The object key of the source code file in the S3 bucket.
- `object_version` (optional): The version of the S3 object to use. If not specified, the latest version is used.

### Example

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

- **`cron_expression`** (string, required): The cron expression that specifies when to execute the Lambda function.
- `state` (optional string, default is ENABLED): Indicates whether the cron job is enabled or not. Possible values are ENABLED or DISABLED.
- `input` (string): The input to be passed to the Lambda function.

### Example

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

- `batch_size`: An optional number that specifies the maximum number of messages to retrieve from the SQS queue in each batch. The default value is 10.
- `enabled`: An optional boolean that specifies whether the event source mapping is enabled. The default value is true.
- `filter_criteria_pattern`: An optional string that specifies a pattern to filter the messages retrieved from the SQS queue. The default value is null.
- `function_response_types`: A list of current response type enums applied to the event source mapping for AWS Lambda checkpointing. Valid value is `ReportBatchItemFailures`. Default value is `null`
- `maximum_batching_window_in_seconds`: An optional number that specifies the maximum amount of time to wait before invoking the Lambda function with a batch of messages. The default value is 20.
- `maximum_concurrency`: An optional number that specifies the configuration for scaling the number of concurrent executions of the Lambda function. The default value is 2.
- **`sqs_arn`**: A required string that specifies the ARN of the Amazon Simple Queue Service (SQS) queue to use as the event source for the Lambda function.

## Example

```hcl
module "lambda_function" {
  # ... other variables ...

  sqs_event_trigger = {
    sqs_arn = "arn:aws:sqs:us-west-2:111111111111:dlq"
  }
}
```

## SQS_TARGET_CONFIG

A target config for SQS. It provides all basic permissions to work with SQS.

- `targets`: A list of SQS ARNs.

## Example

```hcl
module "lambda_function" {
  # ... other variables ...

  sqs_target_config = {
    targets = ["arn:aws:sqs:us-west-2:111111111111"]
  }
}
```

## SNS_EVENT_TRIGGER

Lambda can be triggered by a variety of event sources, including Amazon Simple Notification Service (SNS). When a message is added to an SNS topic, a Lambda function can be automatically triggered to process the message.
Additionally, you will need to create the SNS topic separately and specify its ARN in the `topic_arn` property.

- **`topic_arn`** : A required string that specifies the Amazon Resource Name (ARN) of the Amazon SNS topic to use as the event source for the Lambda function.

### Example

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

- `batch_size`: An optional number that specifies the maximum number of records to read from the Kinesis stream in each batch.
- `bisect_batch_on_function_error`: An optional boolean value that indicates whether to split the batch into smaller batches if the function returns an error.
- `enabled`: An optional boolean value that indicates whether the event source mapping is enabled. If false, the event source mapping is not created or updated.
- `filter_criteria_pattern`: An optional string that specifies a pattern used to filter the records in the stream.
- `function_response_types`: An optional list of strings that specifies the types of responses to include in the function's invocation results.
- **`kinesis_arn`**: A required string that specifies the Amazon Resource Name (ARN) of the Amazon Kinesis stream to use as the event source for the Lambda function.
- `maximum_batching_window_in_seconds`: An optional number that specifies the maximum amount of time to wait before invoking the function with a batch of events.
- `maximum_record_age_in_seconds`: An optional number that specifies the maximum age of a record in the Kinesis stream before it is discarded.
- `maximum_retry_attempts`: An optional number that specifies the maximum number of times to retry a failed batch of events.
- `on_failure_destination_sqs_arn`: An optional string that specifies the Amazon Resource Name (ARN) of the SQS queue to send failed events to.
- `parallelization_factor`: An optional number that specifies the number of batches to process concurrently.
- `starting_position`: An optional string that specifies the starting position in the stream. Valid values are "TRIM_HORIZON" (oldest available record), "LATEST" (most recent record), or a timestamp.
- `starting_position_timestamp`: An optional string that specifies the timestamp of the record to start reading from.
- `tumbling_window_in_seconds`: An optional number that specifies the duration of the tumbling window (the time period during which records are grouped for processing).

### Example

```hcl
module "lambda_function" {
  # ... other variables ...

  kinesis_event_trigger = {
    kinesis_arn = "arn:aws:kinesis:us-west-2:111111111111:stream_name"
  }
}
```

## KINESIS_TARGET_CONFIG

A target config for Kinesis streams. It provides all basic permissions to work with Kinesis.

- `targets`: A list of Kinesis ARNs.

## Example

```hcl
module "lambda_function" {
  # ... other variables ...

  kinesis_target_config = {
    targets = ["arn:aws:kinesis:us-west-2:111111111111"]
  }
}
```

## MSK_EVENT_TRIGGER

Lambda can use Amazon Managed Streaming for Apache Kafka (MSK) as an event source. When new data is added to a Kafka topic, the event trigger invokes the Lambda function, which can then process the data and take appropriate actions.

- `batch_size`: An optional number that specifies the maximum number of records to read from the Kafka topic in each batch.
- `topic`: A required string that specifies the name of the Kafka topic to use as the event source for the Lambda function.
- `enabled`: An optional boolean value that indicates whether the event source mapping is enabled. If false, the event source mapping is not created or updated.
- `cluster_arn`: A required string that specifies the Amazon Resource Name (ARN) of the Amazon MSK cluster to use as the event source for the Lambda function.
- `starting_position`: An optional string that specifies the starting position in the stream. Valid values are "TRIM_HORIZON" (oldest available record) or "LATEST" (most recent record).

### Example

```hcl
module "lambda_function" {
  # ... other variables ...

  msk_event_trigger = {
    cluster_arn = "arn:aws:kafka:us-west-2:111111111111:cluster_name"
    topics      = ["topic_name"]
  }
}
```

## S3_EVENT_TRIGGER

By using S3 as an event trigger for Lambda, you can process the object data immediately after it is created or deleted, enabling real-time data processing workflows.

- `bucket_name`: A required string that specifies the name of the S3 bucket to use as the event source for the Lambda function.
- `events`: A required list of strings that specifies the types of S3 events that will trigger the Lambda function.
- `filter_prefix`: An optional string that specifies a prefix filter for the S3 event notifications.
- `filter_suffix`: An optional string that specifies a suffix filter for the S3 event notifications.

Note: one one combination of event and filter_prefix can exists.

### Example

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

## S3_TARGET_CONFIG

A target config for S3 buckets. It provides all basic permissions to work with S3.

- `targets`: A list of S3 ARNs.

## Example

```hcl
module "lambda_function" {
  # ... other variables ...

  s3_target_config = {
    targets = ["arn:aws:s3:::bucket-name"]
  }
}
```

## DYNAMO_EVENT_TRIGGER

By using DynamoDB streams as an event source for Lambda, you can process changes to the DynamoDB table data immediately as they occur, enabling real-time data processing workflows.

- `batch_size`: An optional number that specifies the maximum number of stream records that will be sent to the Lambda function in a single batch. The default value is 500.
- `bisect_batch_on_function_error`: An optional boolean that indicates whether to split a batch when one or more records in the batch result in a function error. The default value is false.
- **`dynamo_stream_arn`**: A required string that specifies the ARN of the DynamoDB Stream to use as the event source for the Lambda function.
- `enabled`: An optional boolean that indicates whether the event source mapping is enabled. The default value is true.
- `filter_criteria_pattern`: An optional string that specifies a filter pattern for the stream records. The default value is null.
- `function_response_types`: An optional list of strings that specifies the types of function responses to include in the event. The default value is null.
- `maximum_batching_window_in_seconds`: An optional number that specifies the maximum amount of time to gather records before invoking the function. The default value is 0.
- `maximum_record_age_in_seconds`: An optional number that specifies the maximum age of a record in the stream in seconds. The default value is 604800 (7 days).
- `maximum_retry_attempts`: An optional number that specifies the maximum number of times to retry a failed invocation. The default value is 2.
- `on_failure_destination_sqs_arn`: An optional string that specifies the ARN of the SQS queue to which to send events that could not be processed. The default value is null.
- `parallelization_factor`: An optional number that specifies the number of batches to process in parallel. The default value is 1.
- `starting_position`: An optional string that specifies the position in the stream where the function should start processing events. The default value is "LATEST".
- `starting_position_timestamp`: An optional string that specifies the timestamp in ISO 8601 format where the function should start processing events. The default value is null.
- `tumbling_window_in_seconds`: An optional number that specifies the size of the tumbling window in seconds. The default value is 0.

### Example 1

```hcl
module "lambda_function" {
  # ... other variables ...

  dynamo_event_trigger = {
    dynamo_stream_arn = "arn:aws:dynamodb:us-west-2:111111111111:table/table_name/stream/date"
  }
}
```

### Example 2

DynamoDB event trigger only if item has been removed from the table.

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

## DYNAMO_TARGET_CONFIG

A target config for Dynamo tables. It provides all basic permissions to work with Dynamo.

- `targets`: A list of Dynamo ARNs.

## Example

```hcl
module "lambda_function" {
  # ... other variables ...

  dynamo_target_config = {
    targets = ["arn:aws:dynamodb:us-east-1:111111111111:table/table_name"]
  }
}
```

## API_EVENT_TRIGGER

Lambda can use Amazon API Gateway as an event source

- **`api_id`**: The ID of the API Gateway REST API that should trigger the Lambda function.
- **`http_method`**: The HTTP method (e.g., GET, POST, PUT, DELETE) that should trigger the Lambda function.
- **`stage`**: The name of the API Gateway stage that should trigger the Lambda function.
- **`resource_path`** : The resource path of the API Gateway resource that should trigger the Lambda function.

### Example

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

## LAMBDA_TARGET_CONFIG

A target config for Lambda functions. It provides all basic permissions to work with Lambda.

- `targets`: A list of Lambda ARNs.

## Example

```hcl
module "lambda_function" {
  # ... other variables ...

  lambda_target_config = {
    targets = ["arn:aws:lambda:us-west-2:111111111111:function:lambda_name"]
  }
}
```

## STEP_FUNCTION_TARGET_CONFIG

A target config for Stepfunctions. It provides all basic permissions to work with Stepfunctions.

- `targets`: A list of Stepfunction ARNs.

## Example

```hcl
module "lambda_function" {
  # ... other variables ...

  step_function_target_config = {
    targets = ["arn:aws:states:us-east-1:111111111111:stateMachine:stf-name"]
  }
}
```

## FIREHOSE_TARGET_CONFIG

A target config for Firehose streams. It provides all basic permissions to work with Firehose.

- `targets`: A list of Firehose ARNs.

## Example

```hcl
module "lambda_function" {
  # ... other variables ...

  firehose_target_config = {
    targets = ["arn:aws:firehose:eu-central-1:111111111111:deliverystream/stream_name"]
  }
}
```

## OUTPUTS

- `alias` : This output returns the full terraform resource of the Lambda function's Alias. Returns null if alias is not specified.
- `arn` : This output returns the Amazon Resource Name (ARN) of the Lambda function. If Alias is specified it return arn of the alias.
- `function_name` : This output returns the name of the Lambda function that was created.
- `invoke_arn` : This output returns the ARN of the specific version or alias of the Lambda function that can be invoked.
- `lambda`: This output returns the full terraform resource of the Lambda function that was created, including the function's ARN, name, and various other properties and settings.
- `role` : This output returns the AWS Identity and Access Management (IAM) role object that was created to allow the Lambda function to interact with other AWS services and resources.
