output "s3_bucket_name" {
  value       = aws_s3_bucket.this.bucket
  description = "The name of the bucket we'll be using as blob storage"
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.this.arn
  description = "The ARN of the bucket we'll be using as blob storage"
}

output "datastore_s3_bucket_kms_key_arn" {
  value       = aws_kms_key.s3.arn
  description = "The ARN of the KMS key used to encrypt the Metaflow datastore S3 bucket"
}

output "rds_master_instance_endpoint" {
  value       = aws_db_instance.this.endpoint
  description = "The database connection endpoint in address:port format"
}

output "database_username" {
  value       = var.db_username
  description = "The database username"
}

output "database_password" {
  value       = random_password.this.result
  description = "The database password"
}

output "iam_s3_access_role_arn" {
  value       = aws_iam_role.iam_s3_access_role.arn
  description = "The ARN of the access role that grants access to S3 and surrounding services"
}

output "metaflow_s3_policy_arn" {
  value       = aws_iam_policy.s3_access.arn
  description = "Policy grants access to the Metaflow S3 bucket used for blob storage by the Datastore"
}

output "metaflow_kms_s3_policy_arn" {
  value       = aws_iam_policy.kms_s3.arn
  description = "Policy grants access to the KMS key used to encrypt the Metaflow S3 bucket used for blob storage by the Datastore"
}

output "METAFLOW_DATASTORE_SYSROOT_S3" {
  value       = "s3://${aws_s3_bucket.this.bucket}/metaflow"
  description = "Amazon S3 URL for Metaflow DataStore"
}

output "METAFLOW_DATATOOLS_S3ROOT" {
  value       = "s3://${aws_s3_bucket.this.bucket}/data"
  description = "Amazon S3 URL for Metaflow DataTools"
}