resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

provider "aws" {
  region = "us-west-1"
}

locals {
  resource_prefix = "metaflow"
  resource_suffix = random_string.suffix.result
  tags = {
    "managedBy"   = "terraform"
    "application" = "metaflow-eks"
  }
  cluster_name = "mf-${local.resource_suffix}"
}

data "aws_availability_zones" "available" {
}


module "metaflow-datastore" {
  source  = "outerbounds/metaflow/aws//modules/datastore"
  version = "0.12.0"

  force_destroy_s3_bucket = true

  resource_prefix = local.resource_prefix
  resource_suffix = local.resource_suffix

  metadata_service_security_group_id = module.metaflow-metadata-service.metadata_service_security_group_id
  metaflow_vpc_id                    = module.vpc.vpc_id
  subnet1_id                         = module.vpc.private_subnets[0]
  subnet2_id                         = module.vpc.private_subnets[1]

  standard_tags = local.tags
}

module "metaflow-common" {
  source  = "outerbounds/metaflow/aws//modules/common"
  version = "0.12.0"
}

module "metaflow-metadata-service" {
  source  = "outerbounds/metaflow/aws//modules/metadata-service"
  version = "0.12.0"

  resource_prefix = local.resource_prefix
  resource_suffix = local.resource_suffix

  access_list_cidr_blocks          = []
  enable_api_basic_auth            = true
  database_name                    = module.metaflow-datastore.database_name
  database_password                = module.metaflow-datastore.database_password
  database_username                = module.metaflow-datastore.database_username
  datastore_s3_bucket_kms_key_arn  = module.metaflow-datastore.datastore_s3_bucket_kms_key_arn
  fargate_execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  metaflow_vpc_id                  = module.vpc.vpc_id
  metadata_service_container_image = module.metaflow-common.default_metadata_service_container_image
  rds_master_instance_endpoint     = module.metaflow-datastore.rds_master_instance_endpoint
  s3_bucket_arn                    = module.metaflow-datastore.s3_bucket_arn
  subnet1_id                       = module.vpc.private_subnets[0]
  subnet2_id                       = module.vpc.private_subnets[1]
  vpc_cidr_blocks                  = [module.vpc.vpc_cidr_block]
  with_public_ip                   = var.with_public_ip

  standard_tags = local.tags
}


module "metaflow-ui" {
  source = "outerbounds/metaflow/aws//modules/ui"

  resource_prefix = local.resource_prefix
  resource_suffix = local.resource_suffix

  database_name                   = module.metaflow-datastore.database_name
  database_password               = module.metaflow-datastore.database_password
  database_username               = module.metaflow-datastore.database_username
  datastore_s3_bucket_kms_key_arn = module.metaflow-datastore.datastore_s3_bucket_kms_key_arn
  fargate_execution_role_arn      = aws_iam_role.ecs_execution_role.arn
  iam_partition                   = "aws"
  metaflow_vpc_id                 = module.vpc.vpc_id
  rds_master_instance_endpoint    = module.metaflow-datastore.rds_master_instance_endpoint
  s3_bucket_arn                   = module.metaflow-datastore.s3_bucket_arn
  subnet1_id                       = module.vpc.private_subnets[0]
  subnet2_id                       = module.vpc.private_subnets[1]
  ui_backend_container_image      = module.metaflow-common.default_metadata_service_container_image
  ui_static_container_image       = module.metaflow-common.default_ui_static_container_image
  ui_allow_list                   = []

  METAFLOW_DATASTORE_SYSROOT_S3      = module.metaflow-datastore.METAFLOW_DATASTORE_SYSROOT_S3
  metadata_service_security_group_id = module.metaflow-metadata-service.metadata_service_security_group_id

  extra_ui_static_env_vars  = {}
  extra_ui_backend_env_vars = {}
  standard_tags = local.tags
}

variable "with_public_ip" {
  type    = bool
  default = true
}
