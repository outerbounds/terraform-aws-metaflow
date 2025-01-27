variable "db_instance_type" {
  type        = string
  description = "RDS instance type to launch for PostgresQL database."
  default     = "db.t2.small"
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

variable "db_identifier_prefix" {
  type        = string
  description = "Identifier prefix for the RDS instance"
  default     = ""
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

variable "db_parameters" {
  type        = map(string)
  description = "A map of parameters to apply to the DB instance"
  default     = {}
}

variable "metadata_service_security_group_id" {
  type        = string
  description = "The security group ID used by the MetaData service. We'll grant this access to our DB."
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

variable "db_instance_tags" {
  description = "A map of additional tags for the DB instance"
  type        = map(string)
  default     = {}
}

variable "subnet1_id" {
  type        = string
  description = "First subnet used for availability zone redundancy"
}

variable "subnet2_id" {
  type        = string
  description = "Second subnet used for availability zone redundancy"
}

variable "ca_cert_identifier" {
  type        = string
  description = "RDS CA cert identifier for the DB Instances, or leave blank for RDS default"
  default     = ""
}

variable "apply_immediately" {
  type        = bool
  description = "Apply RDS modifications immediately, or wait for Maintenance Window"
  default     = false
}

variable "maintenance_window" {
  type        = string
  description = "Maintenance Window in format \"ddd:hh24:mi-ddd:hh24:mi\" eg. \"Mon:00:00-Mon:03:00\", or leave blank to randomise"
  default     = ""
}

variable "bucket_key_enabled" {
  type        = bool
  description = "Whether or not to use Amazon S3 Bucket Keys for SSE-KMS"
  default     = false
}

variable "s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket used for Metaflow datastore"
  default     = ""
}
