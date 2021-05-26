variable "resource_prefix" {
  default     = "metaflow"
  description = "string prefix for all resources"
}

variable "resource_suffix" {
  default     = ""
  description = "string suffix for all resources"
}

variable "enable_step_functions" {
  type        = bool
  description = "Provisions infrastructure for step functions if enabled"
}

variable "enable_custom_batch_container_registry" {
  type        = bool
  default     = false
  description = "Provisions infrastructure for custom Amazon ECR container registry if enabled"
}

variable "cpu_max_compute_vcpus" {
  type        = string
  description = "Maximum number of Amazon EC2 vCPUs that our CPU Batch Compute Environment can reach."
  default     = 64
}

variable "cpu_min_compute_vcpus" {
  type        = string
  description = "Minimum number of Amazon EC2 vCPUs that our CPU Batch Compute Environment should maintain."
  default     = 16
}

variable "cpu_desired_compute_vcpus" {
  type        = string
  description = "Desired number of Amazon EC2 vCPUS in our CPU Batch Compute Environment. A non-zero number will ensure instances are always on and avoid some cold-start problems."
  default     = 16
}

variable "large_cpu_max_compute_vcpus" {
  type        = string
  description = "Maximum number of Amazon EC2 vCPUs that our large CPU Batch Compute Environment can reach."
  default     = 128
}

variable "large_cpu_min_compute_vcpus" {
  type        = string
  description = "Minimum number of Amazon EC2 vCPUs that our large CPU Batch Compute Environment should maintain."
  default     = 0
}

variable "large_cpu_desired_compute_vcpus" {
  type        = string
  description = "Desired number of Amazon EC2 vCPUS in our large CPU Batch Compute Environment. A non-zero number will ensure instances are always on and avoid some cold-start problems."
  default     = 0
}

variable "gpu_max_compute_vcpus" {
  type        = string
  description = "Maximum number of Amazon EC2 vCPUs that our GPU Batch Compute Environment can reach."
  default     = 64
}

variable "gpu_min_compute_vcpus" {
  type        = string
  description = "Minimum number of Amazon EC2 vCPUs that our GPU Batch Compute Environment should maintain."
  default     = 0
}

variable "gpu_desired_compute_vcpus" {
  type        = string
  description = "Desired number of Amazon EC2 vCPUS in our GPU Batch Compute Environment. A non-zero number will ensure instances are always on and avoid some cold-start problems."
  default     = 0
}

variable "tags" {
  description = "aws tags"
  type        = map(string)
}

# variables from infra project that defines the VPC we will deploy to

variable "access_list_cidr_blocks" {
  type        = list(string)
  description = "List of CIDRs we want to grant access to our Metaflow Metadata Service. Usually this is our VPN's CIDR blocks."
  default     = []
}

variable "vpc_id" {
  type        = string
  description = "The id of the single VPC we stood up for all Metaflow resources to exist in."
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

variable "metaflow_policy_arn" {
  type        = string
  description = "The ARN of the policy that allows access to s3, kms, snowflake secret"
}
