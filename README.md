## terraform_lambda_builder

This project is created to solve one simple problem - deployment of AWS Lambdas using Terraform.

## How it works:

## Example #1 - simple lambda function

Assuming:

- you have a folder with code of a lambda function located in root directory.

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
