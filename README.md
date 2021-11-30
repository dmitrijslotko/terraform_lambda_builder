## Mandatory Variables

`function_name` is for name of a lambda function.

`file_name` is for path to a source code.

## Optional Variables

`create_lambda_role` - default values is false. If it is ntrue than the module will create a role with basic permissions.

`lambda_runtime` - default value is `nodejs14.x`.

`lambda_memory` - default value is `256`.

`lambda_timeout` - default value is `30`seconds.

`lambda_handler` - default value is `index.handler`. `index` is for main file name `index.js`. `handler` is main exported function name.

`lambda_role` - role for a lambda function.

`cloudwatch_log_retention_in_days` - default is 30 days. The cloudwatch logs for the lambda will be deleted after that time.

`enviroment_variables` - by default it is null.

`reserved_concurrent_executions` - default value is -1.

`layers` - by default no layers are added.

## VPC Variables

To deploy lambda in a VPC use the following fields.

`subnet_ids` - is a list of subnet ids. By default is null.

`security_group_ids` - is a list of security group ids. By default is null.

## EFS Variables

To add an EFS volume to a lambda use the following fields. Please note lambda should be deployed in a VPC to make EFS work.

`add_efs` - default value is `false`. If this value is true then the module will create the default efs volume and efs mount. No additional input is needed.

`efs_access_point` - default values is null. Accepts `aws_efs_access_point` resource type.

`local_mount_path` - default values is `/mnt/efs`. Local mount path should start from /mnt/

## Variables for Image Lambdas

`build_timeout` - default value is `10` minutes.

`artifact_bucket` - default values is null. The bucket to store build artifacts.

`artifact_path` - default values is "_artifacts_". It is used a key for the artifacts.

`image_count` - default value is 5. How many images are stored in the image repository.

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
  source        = "git@github.com:dmitrijslotko/terraform_lambda_builder.git?ref=latest"
  function_name = "my_test_lambda"
  file_name     = "./lambda_1"
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
  source                           = "git@github.com:dmitrijslotko/terraform_lambda_builder.git?ref=v2.1.0"
  function_name                    = "my_test_lambda"
  file_name                        = "./source_code/lambda_1"
  enviroment_variables             = { Application : "demo_project", stage : "dev" }
  lambda_memory                    = 512
  lambda_timeout                   = 60
  cloudwatch_log_retention_in_days = 7
  lambda_role                      = aws_iam_role.lambda_builder_iam_role.arn
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
  for_each                         = toset(["lambda_1", "lambda_2"])
  source                           = "git@github.com:dmitrijslotko/terraform_lambda_builder.git?ref=v2.1.0"
  function_name                    = each.value
  file_name                        = "./source_code/${each.value}"
  enviroment_variables             = { Application : "demo_project", stage : "dev" }
  lambda_memory                    = 512
  lambda_timeout                   = 60
  cloudwatch_log_retention_in_days = 7
  lambda_role                      = aws_iam_role.lambda_builder_iam_role.arn
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
  source               = "git@github.com:dmitrijslotko/terraform_lambda_builder.git?ref=v2.1.0"
  function_name        = each.key
  file_name            = "./source_code/${each.key}"
  lambda_memory        = try(each.value.lambda_memory, 128)
  lambda_timeout       = try(each.value.lambda_timeout, 60)
  lambda_role          = try(each.value.lambda_role, null)
  enviroment_variables = try(each.value.enviroment_variables, null)
}


locals {
  lambda_params = {
    lambda_1 = {
      lambda_memory        = 256
      enviroment_variables = { DYNAMO_DB = "my_private_table" }
    }
    lambda_2 = {
      lambda_timeout = 30
      lambda_role    = aws_iam_role.lambda_builder_iam_role.arn
    }
  }
}
```

Terraform will create two lambdas with different memory, timeout, role and env variable. Other parametrs will have the excact match. Since some parameters are defined only for one lambda it should have a try catch operator inside the module to define a fallback variable. Please note the function_name and file_name value is taken from the key of the loop. The rest of the variables from the value of the loop.

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
  file_name          = "./source_code/lambda_1"
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
  source             = "git@github.com:dmitrijslotko/terraform_lambda_builder.git?ref=v2.1.0"
  function_name      = "lambda_1"
  file_name          = "./source_code/lambda_1"
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
  file_name          = "./source_code/${each.value}"
  subnet_ids         = ["subnet-abc123456", "subnet-xyz123456"]
  security_group_ids = ["sg-00112233"]
  efs_access_point   = aws_efs_access_point.access_point_for_lambda.arn
}
```
