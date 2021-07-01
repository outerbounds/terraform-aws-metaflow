output "metaflow_eventbridge_role_arn" {
  value       = join("", [for arn in aws_iam_role.eventbridge_role.*.arn : arn])
  description = "IAM role for Amazon EventBridge to access AWS Step Functions."
}

output "metaflow_step_functions_dynamodb_policy" {
  value       = var.active ? data.aws_iam_policy_document.step_functions_dynamodb.json : ""
  description = "Policy json allowing access to the step functions dynamodb table."
}

output "metaflow_step_functions_dynamodb_table_arn" {
  value       = join("", [for arn in aws_dynamodb_table.step_functions_state_table.*.arn : arn])
  description = "AWS DynamoDB table arn for tracking AWS Step Functions execution metadata."
}

output "metaflow_step_functions_dynamodb_table_name" {
  value       = join("", [for name in aws_dynamodb_table.step_functions_state_table.*.name : name])
  description = "AWS DynamoDB table name for tracking AWS Step Functions execution metadata."
}

output "metaflow_step_functions_role_arn" {
  value       = join("", [for arn in aws_iam_role.step_functions_role.*.arn : arn])
  description = "IAM role for AWS Step Functions to access AWS resources (AWS Batch, AWS DynamoDB)."
}
