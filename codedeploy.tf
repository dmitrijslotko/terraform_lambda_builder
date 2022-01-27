resource "aws_codedeploy_app" "lambda" {
  count            = var.traffic_routing_type != null ? 1 : 0
  compute_platform = "Lambda"
  name             = var.function_name
}

resource "aws_codedeploy_deployment_config" "lambda_config" {
  count                  = var.traffic_routing_type != null ? 1 : 0
  deployment_config_name = var.function_name
  compute_platform       = "Lambda"

  traffic_routing_config {
    type = var.traffic_routing_type

    time_based_linear {
      interval   = var.routing_interval
      percentage = var.routing_percentage
    }
  }
}

resource "aws_codedeploy_deployment_group" "lambda_deployment_group" {
  count                  = var.traffic_routing_type != null ? 1 : 0
  app_name               = aws_codedeploy_app.lambda[count.index].name
  deployment_group_name  = var.function_name
  service_role_arn       = aws_iam_role.service_role[count.index].arn
  deployment_config_name = aws_codedeploy_deployment_config.lambda_config[count.index].id

  #   auto_rollback_configuration {
  #     enabled = true
  #     events  = ["DEPLOYMENT_STOP_ON_ALARM"]
  #   }

  #   alarm_configuration {
  #     alarms  = [var.alarm_name]
  #     enabled = true
  #   }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }
}
