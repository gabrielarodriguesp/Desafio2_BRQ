resource "aws_sqs_queue" "pedido_queue" {
  name          = "status-pedido-queue.fifo"
  fifo_queue    = true
  delay_seconds = 15
}

resource "aws_sqs_queue_policy" "pedido_queue_policy" {
  queue_url = aws_sqs_queue.pedido_queue.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sqs:SendMessage",
        "Resource" : "${aws_sqs_queue.pedido_queue.arn}"
      }
    ]
  })
}

resource "aws_vpc_endpoint" "sqs_endpoint" {
  vpc_id            = data.aws_vpc.default.id
  service_name      = "com.amazonaws.sa-east-1.sqs"
  vpc_endpoint_type = "Interface"

  subnet_ids = data.aws_subnets.default.ids

  security_group_ids = [aws_security_group.sqs_endpoint_sg.id]

  private_dns_enabled = true
}

resource "aws_security_group" "sqs_endpoint_sg" {
  name        = "sqs-endpoint-sg"
  description = "Permitir acesso da Lambda ao VPC Endpoint da SQS"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
