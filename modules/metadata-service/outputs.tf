output "METAFLOW_SERVICE_INTERNAL_URL" {
  value       = "http://${aws_lb.this.dns_name}/"
  description = "URL for Metadata Service (Accessible in VPC)"
}

output "METAFLOW_SERVICE_URL" {
  value       = var.enable_api_gateway ? "https://${aws_api_gateway_rest_api.this[0].id}.execute-api.${data.aws_region.current.name}.amazonaws.com/api/" : ""
  description = "URL for Metadata Service (Open to Public Access)"
}

output "api_gateway_rest_api_id" {
  value       = var.enable_api_gateway ? aws_api_gateway_rest_api.this[0].id : ""
  description = "The ID of the API Gateway REST API we'll use to accept MetaData service requests to forward to the Fargate API instance"
}

output "api_gateway_rest_api_id_key_id" {
  value       = join("", [for id in aws_api_gateway_api_key.this.*.id : id])
  description = "API Gateway Key ID for Metadata Service. Fetch Key from AWS Console [METAFLOW_SERVICE_AUTH_KEY]"
}

output "migration_function_arn" {
  value       = aws_lambda_function.db_migrate_lambda.arn
  description = "ARN of DB Migration Function"
}

output "metadata_service_security_group_id" {
  value       = aws_security_group.metadata_service_security_group.id
  description = "The security group ID used by the MetaData service. We'll grant this access to our DB."
}

output "metadata_svc_ecs_task_role_arn" {
  value       = aws_iam_role.metadata_svc_ecs_task_role.arn
  description = "This role is passed to AWS ECS' task definition as the `task_role`. This allows the running of the Metaflow Metadata Service to have the proper permissions to speak to other AWS resources."
}

output "network_load_balancer_dns_name" {
  value       = aws_lb.this.dns_name
  description = "The DNS addressable name for the Network Load Balancer that accepts requests and forwards them to our Fargate MetaData service instance(s)"
}
