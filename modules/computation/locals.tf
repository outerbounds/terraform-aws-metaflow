data "aws_iam_role" "batch_execution_role" {
  name = var.batch_execution_role_name
  count = var.batch_execution_role_name == "" ? 0 : 1
}

data "aws_iam_role" "ecs_execution_role" {
  name = var.ecs_execution_role_name
  count = var.ecs_execution_role_name == "" ? 0 : 1
}

locals {
  # Name of Batch service's security group used on the compute environment
  batch_security_group_name = "${var.resource_prefix}batch-compute-environment-security-group${var.resource_suffix}"

  # Prefix name of Batch compute environment
  compute_env_prefix_name = "${var.resource_prefix}cpu${var.resource_suffix}"

  # Name of Batch Queue.
  # replace() ensures names that are composed of just prefix + suffix do not have duplicate dashes
  batch_queue_name = replace("${var.resource_prefix}${var.resource_suffix}", "--", "-")

  # Name of IAM role to create to manage ECS tasks
  ecs_execution_role_name = "${var.resource_prefix}ecs-execution-role${var.resource_suffix}"

  # Name of Batch service IAM role
  batch_execution_role_name = "${var.resource_prefix}batch-execution-role${var.resource_suffix}"

  # Name of ECS IAM role
  ecs_instance_role_name = "${var.resource_prefix}ecs-iam-role${var.resource_suffix}"

  enable_fargate_on_batch = var.batch_type == "fargate"

  batch_execution_role_id = var.batch_execution_role_name == "" ? aws_iam_role.batch_execution_role[0].id : data.batch_execution_role.id
  batch_execution_role_arn = var.batch_execution_role_name == "" ? aws_iam_role.batch_execution_role[0].arn : data.batch_execution_role.arn

  ecs_execution_role_id = var.ecs_execution_role_name == "" ? aws_iam_role.ecs_execution_role[0].id : data.ecs_execution_role.id
  ecs_execution_role_arn = var.ecs_execution_role_name == "" ? aws_iam_role.ecs_execution_role[0].arn : data.ecs_execution_role.arn

  ecs_instance_role_id = var.ecs_instance_role_name == "" ? aws_iam_role.ecs_instance_role[0].id : data.ecs_instance_role.id
  ecs_instance_role_arn = var.ecs_instance_role_name == "" ? aws_iam_role.ecs_instance_role[0].arn : data.ecs_instance_role.arn
}
