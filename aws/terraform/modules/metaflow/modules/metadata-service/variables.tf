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

variable "vpc_cidr_block" {
  type        = string
  description = "The VPC CIDR block that we'll access list on our Metadata Service API to allow all internal communications"
}

variable "subnet_private_1_id" {
  type        = string
  description = "First private subnet used for availability zone redundancy"
}

variable "subnet_private_2_id" {
  type        = string
  description = "Second private subnet used for availability zone redundancy"
}

variable "rds_master_instance_endpoint" {
  type        = string
  description = "The database connection endpoint in address:port format"
}
variable "database_username" {
  type        = string
  description = "The database username"
}

variable "database_password" {
  type        = string
  description = "The database password"
}

variable "fargate_task_role_arn" {
  type        = string
  description = "The IAM role that grants access to S3 and surrounding services which we'll use as our Metadata Service API's task_role for our Fargate instance"
}

variable "fargate_execution_role_arn" {
  type        = string
  description = "The IAM role that grants access to ECS and Batch services which we'll use as our Metadata Service API's execution_role for our Fargate instance"
}

variable "access_list_cidr_blocks" {
  type        = list(string)
  description = "List of CIDRs we want to grant access to our Metaflow Metadata Service. Usually this is our VPN's CIDR blocks."
}

variable "standard_tags" {
  type        = map(string)
  description = "The standard tags to apply to every AWS resource."
}
