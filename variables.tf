#################################################################################
#       Common
#################################################################################

variable "iam_partition" {
  type        = string
  default     = "aws"
  description = "IAM Partition (Select aws-us-gov for AWS GovCloud, otherwise leave as is)"
}

variable "tags" {
  description = "aws tags"
  type        = map(string)
}

variable "resource_prefix" {
  default     = ""
  type        = string
  description = "string prefix for all resources"
}

variable "resource_suffix" {
  default     = ""
  type        = string
  description = "string suffix for all resources"
}

#################################################################################
#        Datastore
#################################################################################

variable "create_datastore" {
  description = "Set to create the datastore components for metaflow such as S3 bucket, Postgres database, etc. This value should be set to true in most cases except if the components created by the module are being deployed in kubernetes or are being created through another means."
  type        = bool
  default     = true
}

variable "force_destroy_s3_bucket" {
  type        = bool
  description = "Empty S3 bucket before destroying via terraform destroy"
  default     = true
}

variable "enable_key_rotation" {
  type        = bool
  description = "Enable key rotation for KMS keys"
  default     = false
}

variable "db_instance_type" {
  type        = string
  description = "RDS instance type to launch for PostgresQL database."
  default     = "db.t3.small"
}

variable "db_engine_version" {
  description = "The database engine version for the RDS instances. This value is also used to determine whether to create an Aurora RDS cluster or a classic RDS instance."
  type        = string
  default     = "14"
}

// -------- If create_datastore is set to false then the following values must be set -----------
variable "database_name" {
  description = "Name of the database to be used when create_datastore is set to false. This variable must be set if you create_datastore is set to false."
  type        = string
  default     = ""
}

variable "database_username" {
  description = "Username for the database when create_datastore is set to false. This variable must be set if you create_datastore is set to false."
  type        = string
  default     = ""
}

variable "database_password" {
  description = "Password for the database when create_datastore is set to false. This variable must be set if you create_datastore is set to false."
  type        = string
  default     = ""
  sensitive   = true
}

variable "database_endpoint" {
  description = "Endpoint for the database when create_datastore is set to false. This variable must be set if you create_datastore is set to false."
  type        = string
  default     = ""
}

variable "metaflow_s3_bucket_arn" {
  description = "ARN of the S3 bucket to be used when create_datastore is set to false. This variable must be set if you create_datastore is set to false."
  type        = string
  default     = ""
}

variable "metaflow_s3_bucket_kms_key_arn" {
  description = "ARN of the KMS key used to encrypt the S3 bucket when create_datastore is set to false. This variable must be set if you create_datastore is set to false."
  type        = string
  default     = ""
}

variable "metaflow_s3_sys_root" {
  description = "The S3 root prefix in the metaflow s3 bucket to use. This variable must be set if you create_datastore is set to false."
  type        = string
  default     = ""
}
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------

#################################################################################
#       AWS Managed: Metadata Service
#################################################################################

variable "create_managed_metaflow_metadata_service" {
  description = "Set to create metaflow metadata-service in managed AWS ECS service. This value should be set to false if the metadata service is deployed within a kubernetes cluster"
  type        = bool
  default     = true
}

variable "access_list_cidr_blocks" {
  type        = list(string)
  description = "List of CIDRs we want to grant access to the Metaflow Metadata Service. Usually this is should be your VPN's CIDR blocks."
  default     = []
}

variable "db_migrate_lambda_zip_file" {
  type        = string
  description = "Output path for the zip file containing the DB migrate lambda"
  default     = null
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

variable "metadata_service_container_image" {
  type        = string
  default     = ""
  description = "Container image for metadata service"
}

#################################################################################
#       AWS Managed: Metadata UI
#################################################################################

variable "create_managed_metaflow_ui" {
  description = "Set to create metaflow UI in managed AWS ECS service. This value should be set to false if the UI is deployed within a kubernetes cluster"
  type        = bool
  default     = false
}

variable "metaflow_ui_is_public" {
  description = "Set to true if you would like to make the metaflow UI load balancer publicly accessible"
  type        = bool
  default     = false
}

variable "ui_certificate_arn" {
  type        = string
  default     = ""
  description = "SSL certificate for UI. This value must be set if create_metaflow_ui is set to true."
}

variable "ui_allow_list" {
  type        = list(string)
  default     = []
  description = "List of CIDRs we want to grant access to our Metaflow UI Service. Usually this is our VPN's CIDR blocks."
}

variable "extra_ui_static_env_vars" {
  type        = map(string)
  default     = {}
  description = "Additional environment variables for UI static app"
}

variable "extra_ui_backend_env_vars" {
  type        = map(string)
  default     = {}
  description = "Additional environment variables for UI backend container"
}

variable "ui_static_container_image" {
  type        = string
  default     = ""
  description = "Container image for the UI frontend app"
}

#################################################################################
#       AWS Manged: Metaflow Compute
#################################################################################

variable "create_managed_compute" {
  description = "Set to create metaflow compute resources in AWS Batch. This value should be set to false if the compute resources are deployed within a kubernetes cluster"
  type        = bool
  default     = true
}

variable "batch_type" {
  type        = string
  description = "AWS Batch Compute Type ('ec2', 'fargate')"
  default     = "ec2"
}

variable "compute_environment_desired_vcpus" {
  type        = number
  description = "Desired Starting VCPUs for Batch Compute Environment [0-16] for EC2 Batch Compute Environment (ignored for Fargate)"
  default     = 8
}

variable "compute_environment_instance_types" {
  type        = list(string)
  description = "The instance types for the compute environment"
  default     = ["c5.large", "c5.xlarge", "c5.2xlarge", "c5.4xlarge", "c5.9xlarge"]
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

#################################################################################
#        Step Functions
#################################################################################

variable "create_step_functions" {
  type        = bool
  description = "Provisions infrastructure for step functions if enabled"
  default     = false
}

#################################################################################
#        ECR
#################################################################################

variable "enable_custom_batch_container_registry" {
  type        = bool
  default     = false
  description = "Provisions infrastructure for custom Amazon ECR container registry if enabled"
}

#################################################################################
#        VPC
#################################################################################

variable "create_vpc" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = bool
  default     = false
}

variable "create_public_subnets_only" {
  description = "Set to create a VPC with only public subnets. Using only public subnets helps reduce AWS costs by removing the need to create a NAT gateway. However, it also increases security risk to your infrastructure since a misconfigured security group can expose your infrastructure on the public internet. Hence we only recommend setting this for experimental deployments."
  type        = bool
  default     = false
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "A list of availability zones names in the region"
  type        = list(string)
  default     = []
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(string)
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = {}
}

variable "existing_vpc_cidr_blocks" {
  type        = list(string)
  description = "The VPC CIDR blocks that we'll access list on our Metadata Service API to allow all internal communications. Needs to be set if create_vpc is set to false"
  default     = []
}

variable "existing_vpc_id" {
  type        = string
  description = "The id of the single VPC we stood up for all Metaflow resources to exist in. Needs to be set if create_vpc is set to false"
  default     = ""
}

variable "existing_private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet ids that will be used to create metaflow components in. If create_vpc is set to false, either private_subnet_ids, public_subnet_ids or both need to be set. Setting private_subnet_ids will result in a more "
  default     = []
}

variable "existing_public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet_ids that will be used to create metaflow components that you want to expose on the public internet. This may need to be set if create_vpc is set to false"
  default     = []
}

#################################################################################
#        EKS
#################################################################################

variable "create_eks_cluster" {
  description = "Set to create an EKS cluster"
  type        = bool
  default     = false
}

variable "node_groups" {
  type        = any
  description = "A key value map of EKS node group definitions that will directly override the inputs top the upstream EKS terraform module."
  default     = {}
}

variable "node_group_defaults" {
  type        = any
  description = "A key value map of EKS node group default configurations that will directly override the inputs top the upstream EKS terraform module."
  default     = {}
}

variable "node_group_iam_role_additional_policies" {
  type        = map(string)
  description = "A list of additional IAM policies to attach to the EKS worker nodes. This value directly overrides the input to the upstream EKS terraform module"
  default     = {}
}

variable "deploy_cluster_autoscaler" {
  type        = bool
  description = "Set to deploy the cluster autoscaler"
  default     = false

}

variable "deploy_metaflow_services_in_eks" {
  description = "Set to deploy metaflow metadata service and metaflow ui via the helm chart."
  type        = bool
  default     = false
}

variable "metaflow_helm_values" {
  description = "These are used to override the default values of the metaflow helm chart"
  type        = any
  default     = {}
}
