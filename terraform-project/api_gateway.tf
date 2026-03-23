resource "aws_api_gateway_rest_api" "tasks_api" {
  name = "tasks_api"
  description = "API for task management"
}

###############################################################################################

resource "aws_api_gateway_resource" "tasks" {
  rest_api_id = aws_api_gateway_rest_api.tasks_api.id
  parent_id = aws_api_gateway_rest_api.tasks_api.root_resource_id
  path_part = "tasks"
}

resource "aws_api_gateway_resource" "task_id" {
  rest_api_id = aws_api_gateway_rest_api.tasks_api.id
  parent_id = aws_api_gateway_resource.tasks.id
  path_part = "{id}"
}

resource "aws_api_gateway_resource" "users" {
  rest_api_id = aws_api_gateway_rest_api.tasks_api.id
  parent_id = aws_api_gateway_rest_api.tasks_api.root_resource_id
  path_part = "users"
}

###############################################################################################

resource "aws_api_gateway_method" "tasks_methods" {
  for_each = toset(["GET", "POST", "OPTIONS"])
  rest_api_id = aws_api_gateway_rest_api.tasks_api.id
  resource_id = aws_api_gateway_resource.tasks.id
  http_method = each.key
  authorization = "NONE"
}

resource "aws_api_gateway_method" "task_id_methods" {
  for_each = toset(["GET", "PUT", "DELETE", "OPTIONS"])
  rest_api_id = aws_api_gateway_rest_api.tasks_api.id
  resource_id = aws_api_gateway_resource.task_id.id
  http_method = each.key
  authorization = "NONE"
}

resource "aws_api_gateway_method" "users_methods" {
  for_each      = toset(["GET", "OPTIONS"])
  rest_api_id   = aws_api_gateway_rest_api.tasks_api.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = each.key
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "tasks_integration" {
  for_each = {
    GET     = aws_lambda_function.get_all_tasks.invoke_arn
    POST    = aws_lambda_function.save_task.invoke_arn
    OPTIONS = "MOCK"
  }
  rest_api_id             = aws_api_gateway_rest_api.tasks_api.id
  resource_id             = aws_api_gateway_resource.tasks.id
  http_method             = each.key
  type                    = each.value == "MOCK" ? "MOCK" : "AWS_PROXY"
  integration_http_method = each.value == "MOCK" ? null : "POST"
  uri                     = each.value == "MOCK" ? null : each.value
  request_templates       = each.value == "MOCK" ? { "application/json" = "{\"statusCode\":200}" } : null
  depends_on              = [aws_api_gateway_method.tasks_methods]
}

resource "aws_api_gateway_integration" "task_id_integration" {
  for_each = {
    GET     = aws_lambda_function.get_task.invoke_arn
    PUT     = aws_lambda_function.update_task.invoke_arn
    DELETE  = aws_lambda_function.delete_task.invoke_arn
    OPTIONS = "MOCK"
  }
  rest_api_id             = aws_api_gateway_rest_api.tasks_api.id
  resource_id             = aws_api_gateway_resource.task_id.id
  http_method             = each.key
  type                    = each.key == "OPTIONS" ? "MOCK" : "AWS_PROXY"
  integration_http_method = each.key == "OPTIONS" ? null : "POST"
  uri                     = each.key == "OPTIONS" ? null : each.value
  request_templates       = each.key == "OPTIONS" ? { "application/json" = "{\"statusCode\":200}" } : null
  depends_on              = [aws_api_gateway_method.task_id_methods]
}

resource "aws_api_gateway_integration" "users_integration" {
  for_each = {
    GET     = aws_lambda_function.get_all_users.invoke_arn
    OPTIONS = "MOCK"
  }
  rest_api_id             = aws_api_gateway_rest_api.tasks_api.id
  resource_id             = aws_api_gateway_resource.users.id
  http_method             = each.key
  type                    = each.key == "OPTIONS" ? "MOCK" : "AWS_PROXY"
  integration_http_method = each.key == "OPTIONS" ? null : "POST"
  uri                     = each.key == "OPTIONS" ? null : each.value
  request_templates       = each.key == "OPTIONS" ? { "application/json" = "{\"statusCode\":200}" } : null
  depends_on              = [aws_api_gateway_method.users_methods]
}

###############################################################################################

resource "aws_api_gateway_method_response" "options_response" {
  for_each = {
    tasks   = aws_api_gateway_resource.tasks.id
    task_id = aws_api_gateway_resource.task_id.id
    users   = aws_api_gateway_resource.users.id
  }
  rest_api_id = aws_api_gateway_rest_api.tasks_api.id
  resource_id = each.value
  http_method = "OPTIONS"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  depends_on = [
    aws_api_gateway_method.tasks_methods,
    aws_api_gateway_method.task_id_methods,
    aws_api_gateway_method.users_methods
  ]
}


resource "aws_api_gateway_integration_response" "options_integration_response" {
  for_each = {
    tasks   = aws_api_gateway_resource.tasks.id
    task_id = aws_api_gateway_resource.task_id.id
    users   = aws_api_gateway_resource.users.id
  }
  rest_api_id = aws_api_gateway_rest_api.tasks_api.id
  resource_id = each.value
  http_method = "OPTIONS"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  response_templates = { "application/json" = "" }

  depends_on = [
    aws_api_gateway_method_response.options_response,
    aws_api_gateway_integration.tasks_integration,
    aws_api_gateway_integration.task_id_integration,
    aws_api_gateway_integration.users_integration
  ]
}

###############################################################################################

resource "aws_lambda_permission" "tasks_lambda_permissions" {
  for_each = {
    get_all_tasks  = aws_lambda_function.get_all_tasks.function_name
    save_task      = aws_lambda_function.save_task.function_name
    get_task       = aws_lambda_function.get_task.function_name
    update_task    = aws_lambda_function.update_task.function_name
    delete_task    = aws_lambda_function.delete_task.function_name
    get_all_users  = aws_lambda_function.get_all_users.function_name
  }
  statement_id  = "AllowExecutionFromAPIGateway-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.tasks_api.execution_arn}/*/*"
}

###############################################################################################

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.tasks_api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.tasks.id,
      aws_api_gateway_resource.task_id.id,
      aws_api_gateway_resource.users.id,
      aws_api_gateway_integration.tasks_integration,
      aws_api_gateway_integration.task_id_integration,
      aws_api_gateway_integration.users_integration,
      aws_api_gateway_integration_response.options_integration_response
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_api_gateway_method.tasks_methods,
    aws_api_gateway_method.task_id_methods,
    aws_api_gateway_method.users_methods,
    aws_api_gateway_integration.tasks_integration,
    aws_api_gateway_integration.task_id_integration,
    aws_api_gateway_integration.users_integration,
    aws_api_gateway_integration_response.options_integration_response
  ]
}