variable "resource_prefix" {
  type        = string
  description = "Prefix given to all AWS resources to differentiate between applications"
}

variable "resource_suffix" {
  type        = string
  description = "Suffix given to all AWS resources to differentiate between environment and workspace"
}

variable "metaflow_vpc_id" {
  type        = string
  description = "ID of the Metaflow VPC this SageMaker notebook instance is to be deployed in"
}

variable "ecs_instance_role_arn" {
  type        = string
  description = "This role will be granted access to our S3 Bucket which acts as our blob storage."
}

variable "ecs_execution_role_arn" {
  type        = string
  description = "This role will be granted access to our S3 Bucket which acts as our blob storage."
}

variable "aws_batch_service_role_arn" {
  type        = string
  description = "This role will be granted access to our S3 Bucket which acts as our blob storage."
}

variable "db_instance_type" {
  type        = string
  description = "RDS instance type to launch for PostgresQL database."
  default     = "db.t2.small"
}

variable "db_name" {
  type        = string
  description = "Name of PostgresQL database for Metaflow service."
  default     = "metaflow"
}

variable "db_username" {
  type        = string
  description = "PostgresQL username; defaults to 'metaflow'"
  default     = "metaflow"
}

variable "subnet_private_1_id" {
  type        = string
  description = "First private subnet used for availability zone redundancy"
}

variable "subnet_private_2_id" {
  type        = string
  description = "Second private subnet used for availability zone redundancy"
}

variable "metadata_service_security_group_id" {
  type        = string
  description = "The security group ID used by the MetaData service. We'll grant this access to our DB."
}

variable "standard_tags" {
  type        = map(string)
  description = "The standard tags to apply to every AWS resource."
}
