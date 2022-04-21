###############################################################################
# An example using this module to set up a minimal deployment Metaflow
# with AWS Batch support, without the UI.
###############################################################################

# Random suffix for this deployment
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  resource_prefix = "metaflow"
  resource_suffix = random_string.suffix.result
}

data "aws_availability_zones" "available" {
}

# VPC infra using https://github.com/terraform-aws-modules/terraform-aws-vpc
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.13.0"

  name = "${local.resource_prefix}-${local.resource_suffix}"
  cidr = "10.10.0.0/16"

  azs             = data.aws_availability_zones.available.names
  private_subnets = ["10.10.8.0/21", "10.10.16.0/21", "10.10.24.0/21"]
  public_subnets  = ["10.10.128.0/21", "10.10.136.0/21", "10.10.144.0/21"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}


module "metaflow" {
  source  = "outerbounds/metaflow/aws"
  version = "0.3.0"

  resource_prefix = local.resource_prefix
  resource_suffix = local.resource_suffix

  enable_step_functions = false
  subnet1_id            = module.vpc.public_subnets[0]
  subnet2_id            = module.vpc.public_subnets[1]
  vpc_cidr_block        = module.vpc.vpc_cidr_block
  vpc_id                = module.vpc.vpc_id

  tags = {
    "managedBy" = "terraform"
  }
}

# The module will generate a Metaflow config in JSON format, write it to a file
resource "local_file" "metaflow_config" {
  content  = module.metaflow.metaflow_profile_json
  filename = "./metaflow_profile.json"
}
