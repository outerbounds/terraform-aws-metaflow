locals {
  # Name of Batch service's security group used on the compute environment
  batch_security_group_name = "${var.resource_prefix}batch-compute-environment-security-group${var.resource_suffix}"

  # Prefix name of Batch CPU compute environment
  cpu_compute_env_prefix_name = "${var.resource_prefix}cpu${var.resource_suffix}"

  # Prefix name of Batch CPU compute environment
  large_cpu_compute_env_prefix_name = "${var.resource_prefix}large-cpu${var.resource_suffix}"

  # Prefix name of Batch GPU compute environment
  gpu_compute_env_prefix_name = "${var.resource_prefix}gpu${var.resource_suffix}"

  # Name of Batch Queue.
  # replace() ensures names that are composed of just prefix + suffix do not have duplicate dashes
  batch_queue_name = replace("${var.resource_prefix}${var.resource_suffix}", "--", "-")

  # Name of IAM role to create to manage ECS tasks
  ecs_execution_role_name = "${var.resource_prefix}ecs-execution-role${var.resource_suffix}"

  # Name of Batch service IAM role
  batch_service_role_name = "${var.resource_prefix}batch-service-iam-role${var.resource_suffix}"

  # Name of ECS IAM role
  ecs_instance_role_name = "${var.resource_prefix}ecs-iam-role${var.resource_suffix}"
}
