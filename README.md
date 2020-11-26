## terraform_lambda_builder

This project is created to solve one simple problem - deploy AWS Lambdas using Terraform.

## How it works:

0. Create a module resource and specify the source with the latest version tag. Please pass the "stage" and "stack_name" in the module.

```hcl
   module "lambda_builder" {
      source = "git@github.com:dmitrijslotko/terraform_lambda_builder.git?ref=v1.0.0"
      stage = "dev"
      stack_name = "my_test"
   }
```

Make sure the version tag is the latest.
If ssh key is configured correctly the "terraform init" command will download the module.
To have the ability to modify and commit the changes please move the "lambda_builder" folder to the root directory and update the source param like the example below

```hcl
   module "lambda_builder" {
      source = "./lambda_builder"
      stage = "dev"
      stack_name = "my_test"
   }
```

For more details please see https://www.terraform.io/docs/modules/sources.html#github
Now you can modify the module.

1. Create a new folder index.js file for a new lambda in the "source_code/lambda_code" directory. Please use "lambda_example1" and "lambda_example2" folders as an example.

2. Add a new object in locals in "lambda_builder.tf". Please use "lambda_example1" and "lambda_example2" as a reference. If the lambda object is empty like "example1," the lambda parameters will be taken from the "default_params". If you want to specify any of lambda params, please see "lambda_example2" as a reference. Five params are available for modification: timeout, memory, handler, role, and lambda runtime. Since this project is built for NodeJS, it would not work for other runtimes.
3. To add libraries please use "package.json" in "source_code/layer/nodejs/" directory. No need to use "npm install". This action is performed on every deployment. Please use the "source_code/layer/nodejs/utils/" directory to add the custom code you want to have in all lambdas. The example of how to call the custom library is available in "source_code/lambda_code/lambda_example2/index.js"

4. Modify IAM's role in "iam.tf" to meet your needs. By default, the role in "iam.tf" will be applied to all created lambdas.

5. Deploy and enjoy the result.

## Notes:

The AWS Lambda Layer is updating when the checksum of its zip file changes. It means any change in "source_code/layer/" will trigger a new version. In some cases, you can face the error "Error: Provider produced inconsistent final plan". It is a bug in terraform and usually, another deployment attempt will fix the issue.
