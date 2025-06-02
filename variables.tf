variable "access_list_cidr_blocks" {
  type        = list(string)
  description = "List of CIDRs we want to grant access to our Metaflow Metadata Service. Usually this is our VPN's CIDR blocks."
  default     = []
}

variable "batch_type" {
  type        = string
  description = "AWS Batch Compute Type ('ec2', 'fargate')"
  default     = "ec2"
}

variable "db_migrate_lambda_zip_file" {
  type        = string
  description = "Output path for the zip file containing the DB migrate lambda"
  default     = null
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

variable "db_instance_type" {
  type        = string
  description = "RDS instance type to launch for PostgresQL database."
  default     = "db.t3.small"
}

variable "db_engine_version" {
  type    = string
  default = "11"
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

variable "metadata_service_enable_api_basic_auth" {
  type        = bool
  default     = true
  description = "Enable basic auth for API Gateway? (requires key export)"
}

variable "metadata_service_enable_api_gateway" {
  type        = bool
  default     = true
  description = "Enable API Gateway for public metadata service endpoint"
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

variable "ui_alb_internal" {
  type        = bool
  description = "Defines whether the ALB for the UI is internal"
  default     = false
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
  default     = ""
  description = "SSL certificate for UI. If set to empty string, UI is disabled. "
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
  description = "Enable public IP assignment for the Metadata Service. If the subnets specified for subnet1_id and subnet2_id are public subnets, you will NEED to set this to true to allow pulling container images from public registries. Otherwise this should be set to false."
}

variable "force_destroy_s3_bucket" {
  type        = bool
  description = "Empty S3 bucket before destroying via terraform destroy"
  default     = false
}

variable "enable_key_rotation" {
  type        = bool
  description = "Enable key rotation for KMS keys"
  default     = false
}
