
variable "database_password" {
  type        = string
  description = "The database password"
}

variable "database_username" {
  type        = string
  description = "The database username"
}

variable "datastore_s3_bucket_kms_key_arn" {
  type        = string
  description = "The ARN of the KMS key used to encrypt the Metaflow datastore S3 bucket"
}

variable "fargate_execution_role_arn" {
  type        = string
  description = "The IAM role that grants access to ECS and Batch services which we'll use as our Metadata Service API's execution_role for our Fargate instance"
}

variable "iam_partition" {
  type        = string
  default     = "aws"
  description = "IAM Partition (Select aws-us-gov for AWS GovCloud, otherwise leave as is)"
}

variable "is_gov" {
  type        = bool
  default     = false
  description = "Set to true if IAM partition is 'aws-us-gov'"
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

variable "rds_master_instance_endpoint" {
  type        = string
  description = "The database connection endpoint in address:port format"
}

variable "s3_bucket_arn" {
  type        = string
  description = "The ARN of the bucket we'll be using as blob storage"
}

variable "METAFLOW_DATASTORE_SYSROOT_S3" {
  type        = string
  description = "METAFLOW_DATASTORE_SYSROOT_S3 value"
}

variable "standard_tags" {
  type        = map(string)
  description = "The standard tags to apply to every AWS resource."
}

variable "subnet1_id" {
  type        = string
  description = "First private subnet used for availability zone redundancy"
}

variable "subnet2_id" {
  type        = string
  description = "Second private subnet used for availability zone redundancy"
}

variable "vpc_cidr_block" {
  type        = string
  description = "The VPC CIDR block that we'll access list on our Metadata Service API to allow all internal communications"
}

variable "certificate_arn" {
  type        = string
  description = "SSL certificate ARN"
}

variable "metadata_service_security_group_id" {
  type        = string
  description = "The security group ID used by the MetaData service. We'll grant this access to our DB."
}

variable "extra_ui_backend_env_vars" {
  type = map(string)
  default = {}
  description = "Additional environment variables for UI backend container"
}

variable "extra_ui_static_env_vars" {
  type = map(string)
  default = {}
  description = "Additional environment variables for UI static app"
}

variable "ui_backend_container_image" { 
  type = string
  default = "netflixoss/metaflow_metadata_service:2.1.0"
  description = "Container image for UI backend"
}

variable "ui_static_container_image" { 
  type = string
  default = "public.ecr.aws/outerbounds/metaflow_ui:v1.0.1"
  description = "Container image for UI static app"
}