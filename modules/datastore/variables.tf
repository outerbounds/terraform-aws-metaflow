variable "db_instance_type" {
  type        = string
  description = "RDS instance type to launch for PostgresQL database."
  default     = "db.t3.small"
}

variable "db_engine" {
  type    = string
  default = "postgres"
}

variable "db_engine_version" {
  type    = string
  default = "11"
}

variable "db_name" {
  type        = string
  description = "Name of PostgresQL database for Metaflow service."
  default     = "metaflow"
}

variable "force_destroy_s3_bucket" {
  type        = bool
  description = "Empty S3 bucket before destroying via terraform destroy"
  default     = false
}
variable "db_username" {
  type        = string
  description = "PostgresQL username; defaults to 'metaflow'"
  default     = "metaflow"
}

variable "metadata_service_security_group_id" {
  type        = string
  description = "DEPRECATED: The security group ID used by the MetaData service. We'll grant this access to our DB."
  default     = ""
}

variable "allowed_security_group_ids" {
  description = "A list of security group ids that have access to the RDS instance"
  type        = list(string)
  default     = []
}

variable "vpc_cidr_blocks" {
  type        = list(string)
  description = "Current CIDR block for the VPC"
}

variable "metaflow_vpc_id" {
  type        = string
  description = "ID of the Metaflow VPC this SageMaker notebook instance is to be deployed in"
}

variable "resource_prefix" {
  type        = string
  description = "Prefix given to all AWS resources to differentiate between applications"
}

variable "resource_suffix" {
  type        = string
  description = "Suffix given to all AWS resources to differentiate between environment and workspace"
}

variable "standard_tags" {
  type        = map(string)
  description = "The standard tags to apply to every AWS resource."
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnets to use for creating database instances"
}

variable "enable_key_rotation" {
  type        = bool
  description = "Enable key rotation for KMS keys"
  default     = false
}
