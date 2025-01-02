module "metaflow-common" {
  source = "./modules/common"
}

resource "random_string" "alphanumeric" {
  count   = var.resource_prefix == "" ? 1 : 0
  length  = 5
  special = false
  upper   = false
}

locals {
  resource_prefix = var.resource_prefix == "" ? "metaflow-${random_string.alphanumeric[0].result}" : var.resource_prefix
  resource_suffix = var.resource_suffix != "" ? "-${var.resource_suffix}" : ""

  # VPC related locals
  vpc_id             = var.create_vpc ? module.vpc[0].vpc_id : var.existing_vpc_id
  azs                = length(var.azs) > 0 ? var.azs : slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnet_ids = var.create_vpc && !var.create_public_subnets_only ? module.vpc[0].private_subnets : var.existing_private_subnet_ids
  public_subnet_ids  = var.create_vpc ? module.vpc[0].private_subnets : var.existing_public_subnet_ids
  vpc_cidr_block     = var.create_vpc ? [module.vpc[0].vpc_cidr_block] : var.existing_vpc_cidr_blocks
  subnet_ids         = length(local.private_subnet_ids) > 0 ? local.private_subnet_ids : local.public_subnet_ids
  with_public_ip     = length(local.private_subnet_ids) == 0
  alb_subnet_ids     = var.metaflow_ui_is_public ? local.public_subnet_ids : local.subnet_ids

  metadata_service_container_image = (
    var.metadata_service_container_image == "" ?
    module.metaflow-common.default_metadata_service_container_image :
    var.metadata_service_container_image
  )

  aws_region     = data.aws_region.current.name
  aws_account_id = data.aws_caller_identity.current.account_id

  batch_s3_task_role_name   = "${local.resource_prefix}batch_s3_task_role${local.resource_suffix}"
  metaflow_batch_image_name = "${local.resource_prefix}batch${local.resource_suffix}"
  eks_name                  = "${local.resource_prefix}-eks${local.resource_suffix}"

  database_name                   = var.create_datastore ? module.metaflow-datastore[0].database_name : var.database_name
  database_password               = var.create_datastore ? module.metaflow-datastore[0].database_password : var.database_password
  database_username               = var.create_datastore ? module.metaflow-datastore[0].database_username : var.database_username
  rds_master_instance_endpoint    = var.create_datastore ? module.metaflow-datastore[0].rds_master_instance_endpoint : var.database_endpoint
  datastore_s3_bucket_kms_key_arn = var.create_datastore ? module.metaflow-datastore[0].datastore_s3_bucket_kms_key_arn : var.metaflow_s3_bucket_kms_key_arn
  s3_bucket_arn                   = var.create_datastore ? module.metaflow-datastore[0].s3_bucket_arn : var.metaflow_s3_bucket_arn
  METAFLOW_DATASTORE_SYSROOT_S3   = var.create_datastore ? module.metaflow-datastore[0].METAFLOW_DATASTORE_SYSROOT_S3 : var.metaflow_s3_sys_root


  sgs_access_to_rds = var.create_managed_metaflow_metadata_service ? [module.metaflow-metadata-service[0].metadata_service_security_group_id] : []
}
