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

variable "subnet_private_1_id" {
  type        = string
  description = "The first private subnet used for redundancy"
}

variable "subnet_private_2_id" {
  type        = string
  description = "The second private subnet used for redundancy"
}

variable "s3_kms_policy_arn" {
  type        = string
  description = "Policy grants access to the KMS key used to encrypt the Metaflow S3 bucket used for blob storage by the Datastore"
}

variable "metaflow_policy_arn" {
  type        = string
  description = "The ARN of the policy that allows access to s3, kms, and secrets"
}

variable "standard_tags" {
  type        = map(string)
  description = "The standard tags to apply to every AWS resource."
}

/*
   Often we want the minimum and desired number of vCPUs to be the same. This allows us to often avoid the "cold-start"
   problem associated with AWS Batch, as we'll have a few instances in our cluster at all times.

   This is why we have the same default value set for batch_compute_environment_min_vcpu and batch_compute_environment_desired_vcpu

   These values were empirically found while having a few Data Scientists (~3) using our platform.
*/

variable "batch_compute_environment_cpu_max_vcpus" {
  type        = string
  description = "Maximum number of EC2 vCPUs that our CPU Batch Compute Environment can reach."
  default     = 32
}

variable "batch_compute_environment_cpu_min_vcpus" {
  type        = string
  description = "Minimum number of EC2 vCPUs that our CPU Batch Compute Environment should maintain."
  default     = 0
}

variable "batch_compute_environment_cpu_desired_vcpus" {
  type        = string
  description = "Desired number of EC2 vCPUS in our CPU Batch Compute Environment. A non-zero number will ensure instances are always on and avoid some cold-start problems."
  default     = 0
}

variable "batch_compute_environment_large_cpu_max_vcpus" {
  type        = string
  description = "Maximum number of EC2 vCPUs that our large CPU Batch Compute Environment can reach."
  default     = 128
}

variable "batch_compute_environment_large_cpu_min_vcpus" {
  type        = string
  description = "Minimum number of EC2 vCPUs that our large CPU Batch Compute Environment should maintain."
  default     = 0
}

variable "batch_compute_environment_large_cpu_desired_vcpus" {
  type        = string
  description = "Desired number of EC2 vCPUS in our large CPU Batch Compute Environment. A non-zero number will ensure instances are always on and avoid some cold-start problems."
  default     = 0
}

variable "batch_compute_environment_gpu_max_vcpus" {
  type        = string
  description = "Maximum number of EC2 vCPUs that our GPU Batch Compute Environment can reach."
  default     = 32
}

variable "batch_compute_environment_gpu_min_vcpus" {
  type        = string
  description = "Minimum number of EC2 vCPUs that our GPU Batch Compute Environment should maintain."
  default     = 0
}

variable "batch_compute_environment_gpu_desired_vcpus" {
  type        = string
  description = "Desired number of EC2 vCPUS in our GPU Batch Compute Environment. A non-zero number will ensure instances are always on and avoid some cold-start problems."
  default     = 0
}

variable "batch_cpu_instance_types" {
  type        = list(string)
  description = "EC2 instance types allowed for CPU Batch jobs. Types can be explicitly or implicitly requested by data scientists."
  default = [
    "r5.large",
    "r5.xlarge",
    "r5.2xlarge",
    "c4.large",
    "c4.xlarge",
    "c4.2xlarge",
    "c4.4xlarge"
  ]
}

variable "batch_large_cpu_instance_types" {
  type        = list(string)
  description = "EC2 instance types allowed for larger CPU Batch jobs. Types can be explicitly or implicitly requested by data scientists."
  default = [
    "c4.8xlarge",
    "r5.4xlarge",
    "r5.8xlarge",
    "r5.12xlarge"
  ]
}

variable "batch_gpu_instance_types" {
  type        = list(string)
  description = "EC2 instance types allowed for GPU Batch jobs. Types can be explicitly or implicitly requested by data scientists."
  default = [
    "p3.2xlarge"
  ]
}

variable "metaflow_step_functions_dynamodb_policy" {
  type        = string
  description = "IAM policy allowing access to the step functions dynamodb policy"
}

variable "enable_step_functions" {
  default     = false
  description = "If true, apply policies required for step functions"
  type        = bool
}
