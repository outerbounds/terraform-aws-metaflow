locals {
  # Name of ECS cluster.
  # replace() ensures names that are composed of just prefix + suffix do not have duplicate dashes
  ecs_cluster_name = replace("${var.resource_prefix}${var.resource_suffix}", "--", "-")

  is_gov = var.iam_partition == "aws-us-gov"

  # Name of Fargate security group used by the Metadata Service
  ui_backend_security_group_name = "${var.resource_prefix}ui-backend-sg${var.resource_suffix}"
  alb_security_group_name = "${var.resource_prefix}alb-sg${var.resource_suffix}"

  cloudwatch_logs_arn_prefix = "arn:${var.iam_partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}"

  default_ui_backend_env_vars = {
    "MF_METADATA_DB_HOST" = "${replace(var.rds_master_instance_endpoint, ":5432", "")}"
    "MF_METADATA_DB_NAME" = "metaflow"
    "MF_METADATA_DB_PORT" = "5432"
    "MF_METADATA_DB_PSWD" = "${var.database_password}"
    "MF_METADATA_DB_USER" = "${var.database_username}"
    "PATH_PREFIX" = "/api/"
    "MF_DATASTORE_ROOT" = "${var.METAFLOW_DATASTORE_SYSROOT_S3}"
    "METAFLOW_DATASTORE_SYSROOT_S3" = "${var.METAFLOW_DATASTORE_SYSROOT_S3}"
    "LOGLEVEL" = "DEBUG"
    "METAFLOW_SERVICE_URL" = "http://localhost:8083/api/metadata"
    "METAFLOW_DEFAULT_DATASTORE" = "s3"
    "METAFLOW_DEFAULT_METADATA" = "service"
  }

  default_ui_static_env_vars = {}
}

