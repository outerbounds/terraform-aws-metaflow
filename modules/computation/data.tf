data "aws_region" "current" {}

data "aws_ssm_parameter" "ecs_optimized_cpu_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended"
}

data "aws_ssm_parameter" "ecs_optimized_gpu_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/gpu/recommended"
}

data "aws_security_group" "vpc_default" {
  name   = "default"
  vpc_id = var.metaflow_vpc_id
}
