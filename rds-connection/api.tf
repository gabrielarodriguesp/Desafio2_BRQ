resource "aws_api_gateway_rest_api" "pedido_api" {
  name        = "PizzariaAPI"
  description = "API para receber pedidos da Aplicação Angular - Pizzaria"
}

resource "aws_api_gateway_resource" "pedido" {
  rest_api_id = aws_api_gateway_rest_api.pedido_api.id
  parent_id   = aws_api_gateway_rest_api.pedido_api.root_resource_id
  path_part   = "pedido"
}

resource "aws_api_gateway_method" "post_pedido" {
  rest_api_id   = aws_api_gateway_rest_api.pedido_api.id
  resource_id   = aws_api_gateway_resource.pedido.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "cors_response" {
  rest_api_id = aws_api_gateway_rest_api.pedido_api.id
  resource_id = aws_api_gateway_resource.pedido.id
  http_method = aws_api_gateway_method.post_pedido.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"   = true
    "method.response.header.Access-Control-Allow-Methods"  = true
    "method.response.header.Access-Control-Allow-Headers"  = true
    "method.response.header.Access-Control-Expose-Headers" = true
  }


  depends_on = [
    aws_api_gateway_method.post_pedido
  ]
}

resource "aws_api_gateway_integration" "lambda_pedido" {
  rest_api_id             = aws_api_gateway_rest_api.pedido_api.id
  resource_id             = aws_api_gateway_resource.pedido.id
  http_method             = aws_api_gateway_method.post_pedido.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_api-bd.invoke_arn
}

resource "aws_api_gateway_integration_response" "cors_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.pedido_api.id
  resource_id = aws_api_gateway_resource.pedido.id
  http_method = aws_api_gateway_method.post_pedido.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS, POST, GET, PUT, DELETE'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }

  depends_on = [
    aws_api_gateway_integration.lambda_pedido,
    aws_api_gateway_method_response.cors_response
  ]
}

resource "aws_api_gateway_method" "options_pedido" {
  rest_api_id   = aws_api_gateway_rest_api.pedido_api.id
  resource_id   = aws_api_gateway_resource.pedido.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options_response" {
  rest_api_id = aws_api_gateway_rest_api.pedido_api.id
  resource_id = aws_api_gateway_resource.pedido.id
  http_method = aws_api_gateway_method.options_pedido.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }

  depends_on = [
    aws_api_gateway_method.options_pedido
  ]
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = aws_api_gateway_rest_api.pedido_api.id
  resource_id = aws_api_gateway_resource.pedido.id
  http_method = aws_api_gateway_method.options_pedido.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.pedido_api.id
  resource_id = aws_api_gateway_resource.pedido.id
  http_method = aws_api_gateway_method.options_pedido.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST,GET,PUT,DELETE'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [
    aws_api_gateway_integration.options_integration,
    aws_api_gateway_method_response.options_response
  ]
}

resource "aws_api_gateway_deployment" "pedido_deployment" {
  rest_api_id = aws_api_gateway_rest_api.pedido_api.id
  depends_on = [
    aws_api_gateway_method.post_pedido,
    aws_api_gateway_integration.lambda_pedido,
    aws_api_gateway_method.options_pedido,
    aws_api_gateway_integration.options_integration
  ]
}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.pedido_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.pedido_api.id
  stage_name    = "stage-api"
}

resource "aws_cloudwatch_log_group" "cw-logs" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.pedido_api.id}/${aws_api_gateway_stage.api_stage.stage_name}"
  retention_in_days = 7
}