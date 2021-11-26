## Mandatory variables

`function_name` is for name of a lambda function.

`file_name` is for path to a source code.

## Optional variables

`lambda_runtime` - default value is `nodejs14.x`.

`lambda_memory` - default value is `256`.

`lambda_timeout` - default value is `30`seconds.

`lambda_handler` - default value is `index.handler`. `index` is for main file name `index.js`. `handler` is main exported function name.

`lambda_role` - if it is not passed in module than the module will create a role with basic permissions.

`cloudwatch_log_retention_in_days` - default is 30 days. The cloudwatch logs for the lambda will be deleted after that time.

`enviroment_variables` - by default it is null.

`reserved_concurrent_executions` - default value is -1.

`layers` - by default no layers are added.

## VPC variables

To deploy lambda in a VPC use the following fields.

`subnet_ids` - is a list of subnet ids. By default is null.

`security_group_ids` - is a list of security group ids. By default is null.

## EFS variables

To add an EFS volume to a lambda use the following fields. Please note lambda should be deployed in a VPC to make EFS work.

`add_efs` - default value is `false`. If this value is true then the module will create the default efs volume and efs mount. No additional input is needed.

`efs_access_point` - default values is null. Accepts `aws_efs_access_point` resource type.

`local_mount_path` - default values is `/mnt/efs`. Local mount path should start from /mnt/

## Variables for Image lambdas

`build_timeout` - default value is `10` minutes.

`artifact_bucket` - default values is null. The bucket to store build artifacts.

`artifact_path` - default values is "_artifacts_". It is used a key for the artifacts.

`image_count` - default value is 5. How many images are stored in the image repository.

## Example #1 - simple lambda function

Assuming:

- you have a folder with code of a lambda function located in the root directory.

```hcl
   root_directory/
   |── lambda_1/
      |── index.js
```

then the module definition can have only mandatory variables.
`function_name` is for name of a lambda function.
`file_name` is for path to a source code. By default handler is `index.handler` it means the js file with the main function should have `index.js` name and the exported function should have the name `handler`.

```hcl
module "my_test_lambda" {
  source        = "git@github.com:dmitrijslotko/terraform_lambda_builder.git?ref=latest"
  function_name = "my_test_lambda"
  file_name     = "./lambda_1"
}
```

The outcome of the module will be four resources: iam role, iam role policy (with basic permissions), lambda function, log group (with 30 days retantion period) 0. Create a module resource and specify the source with the latest version tag. Specify the `stage` and `stack_name` in the module.
