locals {
  timeout        = 10
  memory         = 256
  lambda_runtime = "nodejs12.x"
  lambdas = {
    redeploy_tasks = {
      name = "redeploy_tasks"
    }
    s3_logs_event = {
      name = "s3_logs_event"
    }
    gtpv1_get_imsi_request = {
      name = "gtpv1_get_imsi_request"
    },
    gtpv1_get_imsi_response = {
      name = "gtpv1_get_imsi_response"
    }
    gtpv1_get_teid_request = {
      name = "gtpv1_get_teid_request"
    }
    gtpv1_get_teid_response = {
      name = "gtpv1_get_teid_response"
    }
    gtpv1_output = {
      name = "gtpv1_output"
    }
    gtpv2_get_imsi_request = {
      name = "gtpv2_get_imsi_request"
    },
    gtpv2_get_imsi_response = {
      name = "gtpv2_get_imsi_response"
    }
    gtpv2_get_teid_request = {
      name = "gtpv2_get_teid_request"
    }
    gtpv2_get_teid_response = {
      name = "gtpv2_get_teid_response"
    }
    gtpv2_output = {
      name = "gtpv2_output"
    }
    imsi_query_output = {
      name = "imsi_query_output"
    }
    imsi_user_input = {
      name = "imsi_user_input"
    }
    get_trace_records = {
      name = "get_trace_records"
    }
  }
}

data "archive_file" "archive" {
  for_each    = local.lambdas
  type        = "zip"
  source_dir  = "source_code/lambda_code/${each.value.name}"
  output_path = ".build/${each.value.name}.zip"
}

resource "aws_lambda_function" "lambdas" {
  for_each         = local.lambdas
  filename         = data.archive_file.archive[each.key].output_path
  function_name    = "${each.value.name}-${local.stack_prefix}"
  handler          = "index.handler"
  timeout          = local.timeout
  layers           = [aws_lambda_layer_version.lambda_layer.arn]
  runtime          = local.lambda_runtime
  source_code_hash = data.archive_file.archive[each.key].output_base64sha256
  role             = aws_iam_role.iam_role.arn
  memory_size      = local.memory

  environment {
    variables = {
      stage = local.stage      
    }
  }
}