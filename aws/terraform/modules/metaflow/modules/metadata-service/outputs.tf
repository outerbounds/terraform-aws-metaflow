output "api_gateway_rest_api_id" {
  value       = aws_api_gateway_rest_api.this.id
  description = "The ID of the API Gateway REST API we'll use to accept MetaData service requests to forward to the Fargate API instance"
}

output "network_load_balancer_dns_name" {
  value       = aws_lb.this.dns_name
  description = "The DNS addressable name for the Network Load Balancer that accepts requests and forwards them to our Fargate MetaData service instance(s)"
}

output "metadata_service_security_group_id" {
  value       = aws_security_group.metadata_service_security_group.id
  description = "The security group ID used by the MetaData service. We'll grant this access to our DB."
}

output "METAFLOW_SERVICE_INTERNAL_URL" {
  value       = "http://${aws_lb.this.dns_name}/"
  description = "URL for Metadata Service (Accessible in VPC)"
}

output "METAFLOW_SERVICE_URL" {
  value       = "https://${aws_api_gateway_rest_api.this.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/api/"
  description = "URL for Metadata Service (Open to Public Access)"
}
