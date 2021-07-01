locals {
  # Name of ECS cluster.
  # replace() ensures names that are composed of just prefix + suffix do not have duplicate dashes
  ecs_cluster_name = replace("${var.resource_prefix}${var.resource_suffix}", "--", "-")

  is_gov = var.iam_partition == "aws-us-gov"

  # Name of Fargate security group used by the Metadata Service
  metadata_service_security_group_name = "${var.resource_prefix}metadata-service-security-group${var.resource_suffix}"

  api_gateway_endpoint_configuration_type = local.is_gov ? "REGIONAL" : "EDGE"
  api_gateway_key_name                    = "${var.resource_prefix}key${var.resource_suffix}"
  api_gateway_stage_name                  = "api"
  api_gateway_usage_plan_name             = "${var.resource_prefix}usage-plan${var.resource_suffix}"

  db_migrate_lambda_source_file = "${path.module}/index.py"
  db_migrate_lambda_zip_file    = "${path.module}/db_migrate_lambda.zip"
  db_migrate_lambda_name        = "${var.resource_prefix}db_migrate${var.resource_suffix}"
  lambda_ecs_execute_role_name  = "${var.resource_prefix}lambda_ecs_execute${var.resource_suffix}"

  cloudwatch_logs_arn_prefix = "arn:${var.iam_partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}"
}
