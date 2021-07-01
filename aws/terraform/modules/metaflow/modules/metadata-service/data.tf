data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_security_group" "vpc_default" {
  name   = "default"
  vpc_id = var.metaflow_vpc_id
}
