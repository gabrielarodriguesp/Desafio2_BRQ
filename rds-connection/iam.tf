###
### CONFIGURAÇÕES LAMBDA API-DB
###

resource "aws_iam_role" "lambda_api-db_role" {
  name = "lambda_api-db_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_api-db_policy" {
  name        = "lambda_api-db_policy"
  description = "Permissões para Lambda acessar RDS e SQS"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow",
        Action = [
          "rds:DescribeDBInstances",
          "rds-db:connect"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "sqs:*"
        ],
        Resource = "${aws_sqs_queue.pedido_queue.arn}"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_api-db_attach" {
  role       = aws_iam_role.lambda_api-db_role.name
  policy_arn = aws_iam_policy.lambda_api-db_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_api-db_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

###
### CONFIGURAÇÕES LAMBDA SQS-DB
###

resource "aws_iam_role" "lambda_sqs-db_role" {
  name = "lambda_sqs-db_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_sqs-db_policy" {
  name        = "lambda_sqs-db_policy"
  description = "Permissões para Lambda acessar RDS e SQS"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = "${aws_sqs_queue.pedido_queue.arn}"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "rds:DescribeDBInstances",
          "rds-db:connect"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sqs-db_attach" {
  role       = aws_iam_role.lambda_sqs-db_role.name
  policy_arn = aws_iam_policy.lambda_sqs-db_policy.arn
}

###
### CONFIGURAÇÕES LAMBDA SCHEDULE
###

resource "aws_iam_role" "lambda_schedule_role" {
  name = "lambda_schedule_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "lambda_schedule_policy" {
  name = "lambda_schedule_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect = "Allow", Action = ["logs:*"], Resource = "*" },
      { Effect = "Allow", Action = ["rds:DescribeDBInstances", "rds-db:connect"], Resource = "*" }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_schedule_attach" {
  role       = aws_iam_role.lambda_schedule_role.name
  policy_arn = aws_iam_policy.lambda_schedule_policy.arn
}