variable "access_list_cidr_blocks" {
  type        = list(string)
  description = "List of CIDRs we want to grant access to our Metaflow Metadata Service. Usually this is our VPN's CIDR blocks."
  default     = []
}

variable "api_basic_auth" {
  type        = bool
  default     = true
  description = "Enable basic auth for API Gateway? (requires key export)"
}

variable "batch_cluster_name" {
  type        = string
  description = "The name of the ECS cluster to use for batch processing"
  default     = ""
}

variable "batch_type" {
  type        = string
  description = "AWS Batch Compute Type ('ec2', 'fargate')"
  default     = "ec2"
}

variable "db_identifier_prefix" {
  type        = string
  description = "Identifier prefix for the RDS instance"
  default     = ""
}

variable "db_instance_type" {
  type        = string
  description = "RDS instance type to launch for PostgresQL database."
  default     = "db.t2.small"
}

variable "db_engine_version" {
  type    = string
  default = "11"
}

variable "db_migrate_lambda_zip_file" {
  type        = string
  description = "Output path for the zip file containing the DB migrate lambda"
  default     = null
}

variable "db_migrate_lambda_runtime" {
  type        = string
  description = "Runtime version for the DB migrate lambda"
  default     = "python3.7"
}

variable "db_parameters" {
  type        = map(string)
  description = "A map of parameters to apply to the DB instance"
  default     = {}
}

variable "db_allow_major_version_upgrade" {
  type        = bool
  description = "Allow major version upgrades for the RDS instance"
  default     = false
}

variable "database_ssl_mode" {
  type        = string
  default     = "disable"
  description = "The database SSL mode"
}

variable "database_ssl_cert_path" {
  type        = string
  default     = ""
  description = "The database SSL certificate path"
}

variable "database_ssl_key_path" {
  type        = string
  default     = ""
  description = "The database SSL key path"
}

variable "database_ssl_root_cert" {
  type        = string
  default     = ""
  description = "The database SSL root certificate"
}

variable "enable_custom_batch_container_registry" {
  type        = bool
  default     = false
  description = "Provisions infrastructure for custom Amazon ECR container registry if enabled"
}

variable "enable_step_functions" {
  type        = bool
  description = "Provisions infrastructure for step functions if enabled"
}

variable "resource_prefix" {
  default     = "metaflow"
  description = "string prefix for all resources"
}

variable "resource_suffix" {
  default     = ""
  description = "string suffix for all resources"
}

variable "compute_environment_desired_vcpus" {
  type        = number
  description = "Desired Starting VCPUs for Batch Compute Environment [0-16] for EC2 Batch Compute Environment (ignored for Fargate)"
  default     = 8
}

variable "compute_environment_instance_types" {
  type        = list(string)
  description = "The instance types for the compute environment"
  default     = ["c4.large", "c4.xlarge", "c4.2xlarge", "c4.4xlarge", "c4.8xlarge"]
}

variable "compute_environment_min_vcpus" {
  type        = number
  description = "Minimum VCPUs for Batch Compute Environment [0-16] for EC2 Batch Compute Environment (ignored for Fargate)"
  default     = 8
}

variable "compute_environment_max_vcpus" {
  type        = number
  description = "Maximum VCPUs for Batch Compute Environment [16-96]"
  default     = 64
}

variable "compute_environment_egress_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDR blocks to which egress is allowed from the Batch Compute environment's security group"
}

variable "launch_template_http_endpoint" {
  type        = string
  description = "Whether the metadata service is available. Can be 'enabled' or 'disabled'"
  default     = "enabled"
}

variable "launch_template_http_tokens" {
  type        = string
  description = "Whether or not the metadata service requires session tokens, also referred to as Instance Metadata Service Version 2 (IMDSv2). Can be 'optional' or 'required'"
  default     = "optional"
}

variable "launch_template_http_put_response_hop_limit" {
  type        = number
  description = "The desired HTTP PUT response hop limit for instance metadata requests. Can be an integer from 1 to 64"
  default     = 2
}

variable "iam_partition" {
  type        = string
  default     = "aws"
  description = "IAM Partition (Select aws-us-gov for AWS GovCloud, otherwise leave as is)"
}

variable "metadata_service_container_image" {
  type        = string
  default     = ""
  description = "Container image for metadata service"
}

variable "ui_static_container_image" {
  type        = string
  default     = ""
  description = "Container image for the UI frontend app"
}

variable "tags" {
  description = "aws tags"
  type        = map(string)
}

variable "db_instance_tags" {
  description = "A map of additional tags for the DB instance"
  type        = map(string)
  default     = {}
}

variable "ui_alb_internal" {
  type        = bool
  description = "Defines whether the ALB for the UI is internal"
  default     = false
}

variable "ui_cognito_user_pool_arn" {
  type        = string
  description = "The ARN of the Cognito user pool"
  default     = ""
}
variable "ui_cognito_user_pool_client_id" {
  type        = string
  description = "The ID of the Cognito user pool client"
  default     = ""
}
variable "ui_cognito_user_pool_domain" {
  type        = string
  description = "The domain of the Cognito user pool"
  default     = ""
}

# variables from infra project that defines the VPC we will deploy to

variable "subnet1_id" {
  type        = string
  description = "First subnet used for availability zone redundancy"
}

variable "subnet2_id" {
  type        = string
  description = "Second subnet used for availability zone redundancy"
}

variable "vpc_cidr_blocks" {
  type        = list(string)
  description = "The VPC CIDR blocks that we'll access list on our Metadata Service API to allow all internal communications"
}

variable "vpc_id" {
  type        = string
  description = "The id of the single VPC we stood up for all Metaflow resources to exist in."
}

variable "ui_certificate_arn" {
  type        = string
  description = "SSL certificate for UI."
}

variable "ui_allow_list" {
  type        = list(string)
  default     = []
  description = "List of CIDRs we want to grant access to our Metaflow UI Service. Usually this is our VPN's CIDR blocks."
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

variable "with_public_ip" {
  type        = bool
  default     = false
  description = "Enable public IP assignment for the Metadata Service. Typically you want this to be set to true if using public subnets as subnet1_id and subnet2_id, and false otherwise"
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
