variable "batch_type" {
  type        = string
  description = "AWS Batch Compute Type ('ec2', 'fargate')"
  default     = "ec2"
}

variable "compute_environment_desired_vcpus" {
  type        = number
  description = "Desired Starting VCPUs for Batch Compute Environment [0-16] for EC2 Batch Compute Environment (ignored for Fargate)"
}

variable "compute_environment_instance_types" {
  type        = list(string)
  description = "The instance types for the compute environment as a comma-separated list"
}

variable "compute_environment_max_vcpus" {
  type        = number
  description = "Maximum VCPUs for Batch Compute Environment [16-96]"
}

variable "compute_environment_min_vcpus" {
  type        = number
  description = "Minimum VCPUs for Batch Compute Environment [0-16] for EC2 Batch Compute Environment (ignored for Fargate)"
}

variable "compute_environment_egress_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDR blocks to which egress is allowed from the Batch Compute environment's security group"
}

variable "compute_environment_additional_security_group_ids" {
  type        = list(string)
  default     = []
  description = "Additional security group ids to apply to the Batch Compute environment"
}

variable "compute_environment_allocation_strategy" {
  type        = string
  default     = "BEST_FIT"
  description = "Allocation strategy for Batch Compute environment (BEST_FIT, BEST_FIT_PROGRESSIVE, SPOT_CAPACITY_OPTIMIZED)"
}

variable "iam_partition" {
  type        = string
  default     = "aws"
  description = "IAM Partition (Select aws-us-gov for AWS GovCloud, otherwise leave as is)"
}

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

variable "standard_tags" {
  type        = map(string)
  description = "The standard tags to apply to every AWS resource."
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of private subnets that will be used to create compute instances"
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

variable "launch_template_image_id" {
  type        = string
  description = "AMI id for launch template, defaults to allow AWS Batch to decide"
  nullable    = true
  default     = null
}
