output "batch_job_queue_arn" {
  value       = aws_batch_job_queue.this.arn
  description = "The ARN of the job queue we'll use to accept Metaflow tasks"
}

output "ecs_execution_role_arn" {
  value       = aws_iam_role.ecs_execution_role.arn
  description = "The IAM role that grants access to ECS and Batch services which we'll use as our Metadata Service API's execution_role for our Fargate instance"
}

output "ecs_instance_role_arn" {
  value       = aws_iam_role.ecs_instance_role.arn
  description = "This role will be granted access to our S3 Bucket which acts as our blob storage."
}

output "batch_service_role_arn" {
  value       = aws_iam_role.batch_service_role.arn
  description = "This role will be granted access to our S3 Bucket which acts as our blob storage."
}

output "METAFLOW_BATCH_JOB_QUEUE" {
  value       = aws_batch_job_queue.this.arn
  description = "AWS Batch Job Queue ARN for Metaflow"
}

output "METAFLOW_ECS_S3_ACCESS_IAM_ROLE" {
  value       = aws_iam_role.batch_service_role.arn
  description = "Role for AWS Batch to Access Amazon S3 ARN"
}

