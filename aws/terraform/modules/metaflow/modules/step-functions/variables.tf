variable "active" {
  default     = false
  description = "When true step function infrastructure is provisioned."
  type        = bool
}

variable "resource_prefix" {
  type        = string
  description = "Prefix given to all AWS resources to differentiate between applications"
}

variable "resource_suffix" {
  type        = string
  description = "Suffix given to all AWS resources to differentiate between environment and workspace"
}

variable "batch_job_queue_arn" {
  type        = string
  description = "Batch job queue arn"
}

variable "standard_tags" {
  type        = map(string)
  description = "The standard tags to apply to every AWS resource."
}

variable "s3_bucket_arn" {
  type        = string
  description = "arn of the metaflow datastore s3 bucket"
}

variable "s3_bucket_kms_arn" {
  type        = string
  description = "arn of the metaflow datastore s3 bucket's kms key"
}

