data "aws_availability_zones" "available" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  count   = var.create_vpc ? 1 : 0

  name = "${local.resource_prefix}-vpc${local.resource_suffix}"
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = var.create_public_subnets_only ? [] : [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 4, i)]
  public_subnets  = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 4, i + 3)]

  enable_nat_gateway   = !var.create_public_subnets_only
  single_nat_gateway   = !var.create_public_subnets_only
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Use custom tags for subnets
  private_subnet_tags = merge(
    var.private_subnet_tags,
    {
      "kubernetes.io/role/internal-elb" = "1"
    },
  )

  public_subnet_tags = merge(
    var.public_subnet_tags,
    {
      "kubernetes.io/role/elb" = "1"
    },
  )

  tags = var.tags
}

moved {
  from = module.metaflow-datastore
  to   = module.metaflow-datastore[0]
}

module "metaflow-datastore" {
  source = "./modules/datastore"
  count  = var.create_datastore ? 1 : 0

  force_destroy_s3_bucket = var.force_destroy_s3_bucket
  enable_key_rotation     = var.enable_key_rotation

  resource_prefix = local.resource_prefix
  resource_suffix = local.resource_suffix

  allowed_security_group_ids = local.sgs_access_to_rds
  metaflow_vpc_id            = local.vpc_id
  subnet_ids                 = local.private_subnet_ids
  vpc_cidr_blocks            = local.vpc_cidr_block

  db_instance_type  = var.db_instance_type
  db_engine_version = var.db_engine_version

  standard_tags = var.tags
}

resource "aws_ecr_repository" "metaflow_batch_image" {
  count = var.enable_custom_batch_container_registry ? 1 : 0

  name = local.metaflow_batch_image_name

  tags = var.tags
}
