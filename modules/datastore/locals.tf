locals {
  # Name of PostgresQL subnet group.
  pg_subnet_group_name = var.db_identifier_prefix != "" ? "${var.db_identifier_prefix}-${var.db_name}" : "${var.resource_prefix}main${var.resource_suffix}"

  # Name of the RDS identifer
  rds_db_identifier = var.db_identifier_prefix != "" ? "${var.db_identifier_prefix}-${var.db_name}" : "${var.resource_prefix}${var.db_name}${var.resource_suffix}"

  # Name of the RDS security group
  rds_security_group_name = "${var.resource_prefix}rds-security-group${var.resource_suffix}"

  # Name of the RDS snapshot identifier
  rds_final_snapshot_identifier = var.db_identifier_prefix != "" ? "${var.db_identifier_prefix}-${var.db_name}-final-snapshot-${random_pet.final_snapshot_id.id}" : "${var.resource_prefix}${var.db_name}-final-snapshot${var.resource_suffix}-${random_pet.final_snapshot_id.id}"

  # Name of S3 bucket
  s3_bucket_name = var.s3_bucket_name != "" ? var.s3_bucket_name : "${var.resource_prefix}s3${var.resource_suffix}"
}
