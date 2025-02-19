###
### CONFIGURAÇÕES LAMBDA API-DB
###

data "archive_file" "lambda_api-db_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_trigger/api-db.py"
  output_path = "lambda_api-db.zip"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_api-bd.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.pedido_api.execution_arn}/*/*"
}

resource "aws_lambda_function" "lambda_api-bd" {
  filename         = data.archive_file.lambda_api-db_zip.output_path
  function_name    = "LambdaFunctionAPItoRDS"
  role             = aws_iam_role.lambda_api-db_role.arn
  runtime          = "python3.10"
  handler          = "api-db.lambda_handler"
  timeout          = 10
  memory_size      = 1024
  source_code_hash = data.archive_file.lambda_api-db_zip.output_base64sha256

  vpc_config {
    subnet_ids         = data.aws_subnets.default.ids
    security_group_ids = ["${aws_security_group.sg-rds.id}"]
  }

  environment {
    variables = {
      RDS_HOST      = aws_db_instance.mysql.address
      DB_USER       = aws_db_instance.mysql.username
      DB_PASS       = aws_db_instance.mysql.password
      DB_NAME       = aws_db_instance.mysql.db_name
      SQS_QUEUE_URL = aws_sqs_queue.pedido_queue.url
    }
  }

  layers = [
    aws_lambda_layer_version.lambda_layer.arn
  ]

  depends_on = [aws_iam_role_policy_attachment.lambda_api-db_attach]
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "${path.module}/rds_layer/rds_layer.zip"
  layer_name = "rds_layer"

  compatible_runtimes = ["python3.10"]
}

resource "aws_cloudwatch_log_group" "lambda_api-db_log" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_api-bd.function_name}"
  retention_in_days = 3
}


###
### CONFIGURAÇÕES LAMBDA SQS-DB
###

data "archive_file" "lambda_sqs-db_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_trigger/sqs-db.py"
  output_path = "lambda_sqs-db.zip"
}


resource "aws_lambda_function" "lambda_sqs-db" {
  filename         = data.archive_file.lambda_sqs-db_zip.output_path
  function_name    = "LambdaFunctionSQStoRDS"
  role             = aws_iam_role.lambda_sqs-db_role.arn
  runtime          = "python3.10"
  handler          = "sqs-db.lambda_handler"
  timeout          = 10
  source_code_hash = data.archive_file.lambda_sqs-db_zip.output_base64sha256

  vpc_config {
    subnet_ids         = data.aws_subnets.default.ids
    security_group_ids = ["${aws_security_group.sg-rds.id}"]
  }

  environment {
    variables = {
      RDS_HOST      = aws_db_instance.mysql.address
      DB_USER       = aws_db_instance.mysql.username
      DB_PASS       = aws_db_instance.mysql.password
      DB_NAME       = aws_db_instance.mysql.db_name
      SQS_QUEUE_URL = aws_sqs_queue.pedido_queue.url
    }
  }

  layers = [
    aws_lambda_layer_version.lambda_layer.arn
  ]

  depends_on = [
    aws_iam_role_policy_attachment.lambda_sqs-db_attach,
    aws_vpc_endpoint.sqs_endpoint
  ]
}

resource "aws_lambda_event_source_mapping" "lambda_sqs_trigger" {
  event_source_arn = aws_sqs_queue.pedido_queue.arn
  function_name    = aws_lambda_function.lambda_sqs-db.arn
  batch_size       = 1
  enabled          = true
}

resource "aws_lambda_permission" "sqs_invoke" {
  statement_id  = "AllowSQSTrigger"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_sqs-db.arn
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.pedido_queue.arn
}


resource "aws_cloudwatch_log_group" "lambda_sqs-db_log" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_sqs-db.function_name}"
  retention_in_days = 3
}


###
### CONFIGURAÇÕES LAMBDA SCHEDULE
###

data "archive_file" "lambda_schedule_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_trigger/schedule.py"
  output_path = "lambda_schedule.zip"
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_schedule.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_schedule.arn
}

resource "aws_lambda_function" "lambda_schedule" {
  filename      = "lambda_schedule.zip"
  function_name = "lambda_schedule"
  role          = aws_iam_role.lambda_schedule_role.arn
  handler       = "schedule.lambda_handler"
  runtime       = "python3.10"
  timeout       = 10

  environment {
    variables = {
      RDS_HOST = aws_db_instance.mysql.address
      DB_USER  = aws_db_instance.mysql.username
      DB_PASS  = aws_db_instance.mysql.password
      DB_NAME  = aws_db_instance.mysql.db_name
    }
  }

  layers = [
    aws_lambda_layer_version.lambda_layer.arn
  ]

  depends_on = [aws_iam_role_policy_attachment.lambda_schedule_attach]
}


resource "aws_cloudwatch_event_rule" "daily_schedule" {
  name                = "lambda_schedule_daily_schedule"
  schedule_expression = "cron(0/2 17-19 * * ? *)" # 21h UTC = 18h BRT // 8-17 = between 8:00 am and 5:55 pm UTC
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule = aws_cloudwatch_event_rule.daily_schedule.name
  arn  = aws_lambda_function.lambda_schedule.arn
}

resource "aws_cloudwatch_log_group" "lambda_schedule_log" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_schedule.function_name}"
  retention_in_days = 3
}