
# VPC infra using https://github.com/terraform-aws-modules/terraform-aws-vpc
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "${local.resource_prefix}-${local.resource_suffix}"
  cidr = "10.30.0.0/16"

  azs             = data.aws_availability_zones.available.names
  private_subnets = ["10.30.8.0/21", "10.30.16.0/21", "10.30.24.0/21"]
  public_subnets  = ["10.30.128.0/21", "10.30.136.0/21", "10.30.144.0/21"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}
