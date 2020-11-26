## terraform_lambda_builder

This project is created to solve one simple problem - deployment of AWS Lambdas using Terraform.   

## How it works:

0. Create a module resource and specify the source with the latest version tag. Specify the `stage` and `stack_name` in the module.

```hcl
   module "lambda_builder" {
      source = "git@github.com:dmitrijslotko/terraform_lambda_builder.git?ref=v1.0.0"
      stage = "dev"
      stack_name = "my_test"
   }
```

Make sure that the version tag is the latest.
If ssh key is configured correctly the `terraform init` command will download the module.
In order to be able to modify and commit the changes - move the `lambda_builder` folder to the root directory and update the source param like in the example below

```hcl
   module "lambda_builder" {
      source = "./lambda_builder"
      stage = "dev"
      stack_name = "my_test"
   }
```

For more details please see https://www.terraform.io/docs/modules/sources.html#github

Now you can modify the module.

1. Create a new folder with index.js file for a new lambda in the `source_code/lambda_code` directory. Use `lambda_example1` and `lambda_example2` folders as an example.

2. Add a new object to locals in `lambda_builder.tf`. Use `lambda_example1` and `lambda_example2` as a reference. If the lambda object is empty like `example1` the lambda parameters will be taken from the `default_params`. Use `lambda_example2` as a reference on how to specify lambda params. Five params are available for modification: timeout, memory, handler, role, and lambda runtime. Since this project is built for NodeJS, it would not work for other runtimes.

3. To add libraries you have to edit `package.json` in `source_code/layer/nodejs/` directory. There is no need to use `npm install`. This action is performed on every deployment. Use the `source_code/layer/nodejs/utils/` directory to add the custom code you want to have in all lambdas. The example of how to call the custom library is available in `source_code/lambda_code/lambda_example2/index.js`

4. Modify IAM's role in `iam.tf` to meet your needs. By default, the role in `iam.tf` will be applied to all created lambdas.

5. Deploy and enjoy the result.

## Notes:

The AWS Lambda Layer is updated when the checksum of its zip file changes. It means that any change in `source_code/layer/` will trigger a new version. In some cases, you can face the error `Error: Provider produced inconsistent final plan`. It is a bug in terraform and usually, another deployment attempt fixes the issue.
