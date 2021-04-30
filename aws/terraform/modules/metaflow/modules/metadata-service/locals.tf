locals {
  # Name of ECS cluster.
  # replace() ensures names that are composed of just prefix + suffix do not have duplicate dashes
  ecs_cluster_name = replace("${var.resource_prefix}${var.resource_suffix}", "--", "-")

  # Name of Fargate security group used by the Metadata Service
  metadata_service_security_group_name = "${var.resource_prefix}metadata-service-security-group${var.resource_suffix}"
}
