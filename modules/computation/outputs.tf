output "METAFLOW_BATCH_JOB_QUEUE" {
  value       = aws_batch_job_queue.this.arn
  description = "AWS Batch Job Queue ARN for Metaflow"
}

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

output "batch_compute_environment_security_group_id" {
  value       = aws_security_group.this.id
  description = "The ID of the security group attached to the Batch Compute environment."
}
