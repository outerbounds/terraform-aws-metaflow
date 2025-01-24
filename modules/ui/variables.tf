variable "database_name" {
  type        = string
  default     = "metaflow"
  description = "The database name"
}

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
  description = "This role allows Fargate to pull container images and logs. We'll use it as execution_role for our Fargate task"
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
  description = "VPC to deploy services into"
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
  description = "The ARN of the bucket used for Metaflow datastore"
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

variable "certificate_arn" {
  type        = string
  description = "SSL certificate ARN. The certificate will be used by the UI load balancer."
}

variable "metadata_service_security_group_id" {
  type        = string
  description = "The security group ID used by the MetaData service. This security group should allow connections to the RDS instance."
}

variable "extra_ui_backend_env_vars" {
  type        = map(string)
  default     = {}
  description = "Additional environment variables for UI backend container"
}

variable "extra_ui_static_env_vars" {
  type        = map(string)
  default     = {}
  description = "Additional environment variables for UI static app"
}

variable "ui_backend_container_image" {
  type        = string
  default     = ""
  description = "Container image for UI backend"
}

variable "ui_static_container_image" {
  type        = string
  default     = ""
  description = "Container image for the UI frontend app"
}

variable "ui_allow_list" {
  type        = list(string)
  description = "A list of CIDRs the UI will be available to"
  default     = []
}

variable "alb_internal" {
  type        = bool
  description = "Defines whether the ALB is internal"
  default     = false
}

variable "cognito_user_pool_arn" {
  type        = string
  description = "The ARN of the Cognito user pool"
  default     = ""
}
variable "cognito_user_pool_client_id" {
  type        = string
  description = "The ID of the Cognito user pool client"
  default     = ""
}
variable "cognito_user_pool_domain" {
  type        = string
  description = "The domain of the Cognito user pool"
  default     = ""
}

variable "load_balancer_name_prefix" {
  type        = string
  description = "Prefix for all load balancer names"
  default     = ""
}

variable "ecs_cluster_settings" {
  type        = map(string)
  description = "Settings for the ECS cluster"
  default     = {}
}
