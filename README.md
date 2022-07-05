## Mandatory Variables

`function_name` is for name of a lambda function.

`filename` is for path to a source code.

## Optional Variables

`runtime` - default value is `nodejs14.x`.

`memory_size` - default value is `256`.

`timeout` - default value is `30`seconds.

`handler` - default value is `index.handler`. `index` is for main file name `index.js`. `handler` is main exported function name.

`lambda_retention_in_days` - default is 30 days. The cloudwatch logs for the lambda will be deleted after that time.

`environment_variables` - by default it is null.

`layers` - expects to receive a list of layer arns. By default no layers are added.

## VPC Variables

To deploy lambda in a VPC use the following fields.

`subnet_ids` - is a list of subnet ids. By default is null.

`security_group_ids` - is a list of security group ids. By default is null.

## EFS Variables

To add an EFS volume to a lambda use the following fields. Please note lambda should be deployed in a VPC to make EFS work.

`add_efs` - default value is `false`. If this value is true then the module will create the default efs volume and efs mount. No additional input is needed.

## Alias Variables

`alias` - Name for the alias you are creating. When alias has a value `publish` is automaticly enabled for a lambda.

`versions_to_keep` - A number of how many lambda version you want to keep.

`stable_version` - A version which is stable and you want to use it for traffic routing.

`stable_version_weights` - A weight of how much traffic will go to a stable version lambda.

## Alias Variables

`actions_enabled` - Indicates whether the actions should be executed during any changes to the alarm's state. 
Defaults to true. 

`add_alarm` - Indicates whether the alarm should be added. 
Defaults to false. 

`alarm_priority` - The priority of the alarm that will be used as prefix to alarm name. 
The following values are supported: anomaly_detection and error_detection.
Defaults to error_detection.

`alarm_type` - The type of preconfigured alarm to be added if add_alarm is true 
The following values are supported: P1 and P2.
Defaults to P2.

`datapoints_to_alarm` - The number of datapoints that must be breaching to trigger the alarm. 
Defaults to 1.

`evaluation_periods` - The number of periods over which data is compared to the specified threshold. 
Defaults to 5.

`normal_deviation` - The number of standard deviation to be used for the band calculation, i.e. threshold metric. 
Defaults to 2.

`period` - The period in seconds over which the specified statistic is applied.
Defaults to 60.

`sns_topic` - The list of actions to execute when this alarm transitions into an ALARM or OK state from any other state. 
Each action is specified as an Amazon Resource Name (ARN). 
Defaults to null.

`treat_missing_data` - Sets how this alarm is to handle missing data points. 
The following values are supported: breaching and notBreaching. 
Defaults to notBreaching.


## Example #1 - Simple Lambda Function

Assuming:

- you have a folder with code of a lambda function located in the root directory.
- file name is `index.js`
- it has a `handler` as a main function name.

```hcl
   root_directory/
   |── lambda_1/
      |── index.js
```

```hcl
module "my_test_lambda" {
  source         = "git@github.com:dmitrijslotko/terraform_lambda_builder.git?ref=latest"
  function_name  = "my_test_lambda"
  filename       = "./lambda_1"
}
```

## Example #2 - Lambda Function with Additional Parameters

Assuming:

- you have a folder with code of a lambda function located in the root directory.
- file name is `index.js`
- it has a `handler` as a main function name.

```hcl
   root_directory/
   |── source_code/
      |── lambda_1/
         |── index.js
```

```hcl
module "my_test_lambda" {
  source                   = "git@github.com:dmitrijslotko/terraform_lambda_builder.git?ref=latest"
  function_name            = "my_test_lambda"
  filename                 = "./source_code/lambda_1"
  environment_variables     = { Application : "demo_project", stage : "dev" }
  memory_size              = 512
  timeout                  = 60
  lambda_retention_in_days = 7
}
```

To get to the variables of the created lambda function like arn or invoke_arn it is possible to use the output of a module. It will output the aws_lambda_function object. So to get the arn or invoke_arn in this example you can use:

module.my_test_lambda.lambda_output.arn

or

module.my_test_lambda.lambda_output.invoke_arn

## Example #3 - Create Multiple Lambda Functions in a Loop

Assuming:

- you have a folder with code of the lambda functions located in the root directory.
- each file name is `index.js`.
- each file has a `handler` as a main function name.
- you have matching lambda name and a folder name.

```hcl
   root_directory/
   |── source_code/
      |── lambda_1/
         |── index.js
      |── lambda_2/
         |── index.js
```

```hcl
module "my_test_lambda" {
  for_each                 = toset(["lambda_1", "lambda_2"])
  source                   = "git@github.com:dmitrijslotko/terraform_lambda_builder.git?ref=latest"
  function_name            = each.value
  filename                 = "./source_code/${each.value}"
  environment_variables     = { Application : "demo_project", stage : "dev" }
  memory_size              = 512
  timeout                  = 60
  lambda_retention_in_days = 7
}
```

To get the first lambda object in this example please use `module.my_test_lambda["lambda_1"].lambda_output` or if you need the second object than use `module.my_test_lambda["lambda_2"].lambda_output`. To get the arn of a second lambda use `module.my_test_lambda["lambda_2"].lambda_output.arn`

## Example #4 - Create Multiple Lambda Functions in a Loop with Different Parameters

Assuming:

- you have a folder with code of the lambda functions located in the root directory.
- each file name is `index.js`.
- each file has a `handler` as a main function name.
- you have matching lambda name and a folder name.
- you need two lambdas with different input parameters.

```hcl
   root_directory/
   |── source_code/
      |── lambda_1/
         |── index.js
      |── lambda_2/
         |── index.js
```

```hcl
module "my_test_lambda" {
  for_each             = local.lambda_params
  source               = "git@github.com:dmitrijslotko/terraform_lambda_builder.git?ref=latest"
  function_name        = each.key
  filename             = "./source_code/${each.key}"
  memory_size          = try(each.value.memory_size, 128)
  timeout              = try(each.value.timeout, 60)
  environment_variables = try(each.value.environment_variables, null)
}


locals {
  lambda_params = {
    lambda_1 = {
      memory_size          = 256
      environment_variables = { DYNAMO_DB = "my_private_table" }
    }
    lambda_2 = {
      timeout     = 30
    }
  }
}
```

Terraform will create two lambdas with different memory, timeout, role and env variable. Other parametrs will have the excact match. Since some parameters are defined only for one lambda it should have a try catch operator inside the module to define a fallback variable. Please note the function_name and filename value is taken from the key of the loop. The rest of the variables from the value of the loop.

## Example #4 - Create Lambda in a Subnet

Assuming:

- you have a folder with code of a lambda function located in the root directory.
- file name is `index.js`
- it has a `handler` as a main function name.
- subnets are previosly created.
- security groups are previosly created.

```hcl
   root_directory/
   |── source_code/
      |── lambda_1/
         |── index.js
```

```hcl
module "my_test_lambda" {
  source             = "git@github.com:dmitrijslotko/terraform_lambda_builder.git?ref=v2.1.0"
  function_name      = "lambda_1"
  filename           = "./source_code/lambda_1"
  subnet_ids         = ["subnet-abc123456", "subnet-xyz123456"]
  security_group_ids = ["sg-00112233"]
}
```

Lambda will be deployed in the selected subnets. Default role will have the necessary permissions for this action.

## Example #5 - Add EFS Volume to a Lambda

Assuming:

- you have a folder with code of a lambda function located in the root directory.
- file name is `index.js`
- it has a `handler` as a main function name.
- subnets are previosly created.
- security groups are previosly created.

```hcl
   root_directory/
   |── source_code/
      |── lambda_1/
         |── index.js
```

```hcl
module "my_test_lambda" {
  source             = "git@github.com:dmitrijslotko/terraform_lambda_builder.git?ref=latest"
  function_name      = "lambda_1"
  filename           = "./source_code/lambda_1"
  subnet_ids         = ["subnet-abc123456", "subnet-xyz123456"]
  security_group_ids = ["sg-00112233"]
  add_efs            = true
}
```

## Example #6 - One EFS Volume Across Two Lambdas

Assuming:

- you have a folder with code of a lambda function located in the root directory.
- file name is `index.js`
- it has a `handler` as a main function name.
- subnets are previosly created.
- security groups are previosly created.
- efs volume is previosly created

```hcl
   root_directory/
   |── source_code/
      |── lambda_1/
         |── index.js
      |── lambda_2/
         |── index.js
```

```hcl
module "my_test_lambda" {
  for_each           = toset(["lambda_1", "lambda_2"])
  source             = "git@github.com:dmitrijslotko/terraform_lambda_builder.git?ref=v2.1.0"
  function_name      = each.value
  filename           = "./source_code/${each.value}"
  subnet_ids         = ["subnet-abc123456", "subnet-xyz123456"]
  security_group_ids = ["sg-00112233"]
  efs_access_point   = aws_efs_access_point.access_point_for_lambda.arn
}
```

## Example #7 - Lambda with an alias and traffic shifting

Assuming:

- you have a folder with code of a lambda function located in the root directory.
- file name is `index.js`
- it has a `handler` as a main function name.
- you have a lambda function with minimum of two versions.

```hcl
   root_directory/
   |── source_code/
      |── lambda_1/
         |── index.js
```

```hcl
module "my_test_lambda" {
  source                 = "git@github.com:dmitrijslotko/terraform_lambda_builder.git?ref=latest"
  function_name          = "my_test_lambda"
  filename               = "./lambda_1"
  alias                  = "live"
  stable_version         = 19
  stable_version_weights = 0.9
}
```

It creates a alias `live`, routes 90% of the traffic to a version `19` and 10% of the traffic to the latest version.

## Example #8 - Lambda with an alarm on errors

Assuming:

- you have a folder with code of a lambda function located in the root directory.
- file name is `index.js`
- it has a `handler` as a main function name.

```hcl
   root_directory/
   |── lambda_1/
      |── index.js
```

```hcl
module "my_test_lambda" {
  source             = "git@github.com:dmitrijslotko/terraform_lambda_builder.git?ref=latest"
  function_name      = "my_test_lambda"
  filename           = "./lambda_1"
  add_alarm          = true
  sns_topic          = "arn:aws:sns:region:account_id:topic_name"
  actions_enabled    = true
  alarm_priority     = "P2"
  treat_missing_data = "notBreaching"
  evaluation_periods = 1
  period             = 60
  alarm_type         = "error_detection"
}
```

It creates an alarm based on errors and throttles. It send both alarm and ok states to the sns topic. It has a prefix P2 at the beggining of the alarm name. It does not goes to the alarm state if data is not receiving any data which makes it perfect for lambdas with infrequent invocations.

## Example #9 - Lambda with an alarm based on anomaly detection

Assuming:

- you have a folder with code of a lambda function located in the root directory.
- file name is `index.js`
- it has a `handler` as a main function name.

```hcl
   root_directory/
   |── lambda_1/
      |── index.js
```

```hcl
module "my_test_lambda" {
  source             = "git@github.com:dmitrijslotko/terraform_lambda_builder.git?ref=latest"
  function_name      = "my_test_lambda"
  filename           = "./lambda_1"
  sns_topic          = "arn:aws:sns:region:account_id:topic_name"
  actions_enabled    = true
  add_alarm          = true
  alarm_priority     = "P1"
  treat_missing_data = "breaching"
  evaluation_periods = 30
  period             = 60
  alarm_type         = "anomaly_detection"
  normal_deviation   = 2
}
```

It creates an alarm based on anomaly detection using five standart lambda metrics. It send both alarm and ok states to the sns topic. It has a prefix P1 at the beggining of the alarm name. It goes to the alarm state if data is not receiving which makes it perfect for lambdas with regular invocations. `normal_deviation` is for upper and lower border of the metrics. Value 2 gives the twice range to the upper and to the lower border of the anomaly detection. The bigger the number the less sensitive is an alarm.
