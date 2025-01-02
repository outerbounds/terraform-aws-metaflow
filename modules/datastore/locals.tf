locals {
  # Name of PostgresQL subnet group.
  pg_subnet_group_name = "${var.resource_prefix}main${var.resource_suffix}"

  # Name of the RDS security group
  rds_security_group_name = "${var.resource_prefix}rds-security-group${var.resource_suffix}"

  # Name of S3 bucket
  s3_bucket_name = "${var.resource_prefix}s3${var.resource_suffix}"

  # Access to RDS instance
  allowed_security_group_ids = var.metadata_service_security_group_id != "" ? concat([var.metadata_service_security_group_id], var.allowed_security_group_ids) : var.allowed_security_group_ids
}
