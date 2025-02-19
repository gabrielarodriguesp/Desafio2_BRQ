output "sqs_url" {
  description = "SQS URL"
  value       = aws_sqs_queue.pedido_queue.url
}

output "deployment_invoke_url" {
  description = "Deployment invoke url"
  value       = aws_api_gateway_deployment.pedido_deployment.invoke_url
}

output "deployment_execution_arn" {
  description = "Deployment execution ARN"
  value       = aws_api_gateway_deployment.pedido_deployment.execution_arn
}

output "hostname_rds" {
  description = "RDS Hostname"
  value       = aws_db_instance.mysql.address
}

