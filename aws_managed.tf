moved {
  from = module.metaflow-metadata-service
  to   = module.metaflow-metadata-service[0]
}

module "metaflow-metadata-service" {
  source = "./modules/metadata-service"

  count = var.create_managed_metaflow_metadata_service ? 1 : 0

  resource_prefix = local.resource_prefix
  resource_suffix = local.resource_suffix

  access_list_cidr_blocks          = var.access_list_cidr_blocks
  database_name                    = local.database_name
  database_password                = local.database_password
  database_username                = local.database_username
  db_migrate_lambda_zip_file       = var.db_migrate_lambda_zip_file
  datastore_s3_bucket_kms_key_arn  = local.datastore_s3_bucket_kms_key_arn
  enable_api_basic_auth            = var.metadata_service_enable_api_basic_auth
  enable_api_gateway               = var.metadata_service_enable_api_gateway
  fargate_execution_role_arn       = module.metaflow-computation[0].ecs_execution_role_arn
  iam_partition                    = var.iam_partition
  metadata_service_container_image = local.metadata_service_container_image
  metaflow_vpc_id                  = local.vpc_id
  rds_master_instance_endpoint     = local.rds_master_instance_endpoint
  s3_bucket_arn                    = local.s3_bucket_arn
  subnet_ids                       = local.subnet_ids
  vpc_cidr_blocks                  = local.vpc_cidr_block
  with_public_ip                   = local.with_public_ip

  standard_tags = var.tags
}

module "metaflow-ui" {
  source = "./modules/ui"
  count  = var.create_managed_metaflow_ui ? 1 : 0

  resource_prefix = local.resource_prefix
  resource_suffix = local.resource_suffix

  database_name                   = local.database_name
  database_password               = local.database_password
  database_username               = local.database_username
  datastore_s3_bucket_kms_key_arn = local.datastore_s3_bucket_kms_key_arn
  fargate_execution_role_arn      = module.metaflow-computation[0].ecs_execution_role_arn
  iam_partition                   = var.iam_partition
  metaflow_vpc_id                 = local.vpc_id
  rds_master_instance_endpoint    = local.rds_master_instance_endpoint
  s3_bucket_arn                   = local.s3_bucket_arn
  subnet_ids                      = local.subnet_ids
  alb_subnet_ids                  = local.alb_subnet_ids
  ui_backend_container_image      = local.metadata_service_container_image
  ui_static_container_image       = var.ui_static_container_image
  alb_internal                    = !var.metaflow_ui_is_public
  ui_allow_list                   = var.ui_allow_list

  METAFLOW_DATASTORE_SYSROOT_S3      = local.METAFLOW_DATASTORE_SYSROOT_S3
  certificate_arn                    = var.ui_certificate_arn
  metadata_service_security_group_id = module.metaflow-metadata-service[0].metadata_service_security_group_id

  extra_ui_static_env_vars  = var.extra_ui_static_env_vars
  extra_ui_backend_env_vars = var.extra_ui_backend_env_vars
  standard_tags             = var.tags
}

moved {
  from = module.metaflow-computation
  to   = module.metaflow-computation[0]
}

module "metaflow-computation" {
  source = "./modules/computation"
  count  = var.create_managed_compute ? 1 : 0

  resource_prefix = local.resource_prefix
  resource_suffix = local.resource_suffix

  batch_type                                  = var.batch_type
  compute_environment_desired_vcpus           = var.compute_environment_desired_vcpus
  compute_environment_instance_types          = var.compute_environment_instance_types
  compute_environment_max_vcpus               = var.compute_environment_max_vcpus
  compute_environment_min_vcpus               = var.compute_environment_min_vcpus
  compute_environment_egress_cidr_blocks      = var.compute_environment_egress_cidr_blocks
  iam_partition                               = var.iam_partition
  metaflow_vpc_id                             = local.vpc_id
  subnet_ids                                  = local.subnet_ids
  launch_template_http_endpoint               = var.launch_template_http_endpoint
  launch_template_http_tokens                 = var.launch_template_http_tokens
  launch_template_http_put_response_hop_limit = var.launch_template_http_put_response_hop_limit

  standard_tags = var.tags
}

moved {
  from = module.metaflow-step-function
  to   = module.metaflow-step-function[0]
}

module "metaflow-step-functions" {
  source = "./modules/step-functions"
  count  = var.create_step_functions ? 1 : 0

  resource_prefix     = local.resource_prefix
  resource_suffix     = local.resource_suffix
  batch_job_queue_arn = module.metaflow-computation[0].METAFLOW_BATCH_JOB_QUEUE
  iam_partition       = var.iam_partition
  s3_bucket_arn       = module.metaflow-datastore[0].s3_bucket_arn
  s3_bucket_kms_arn   = module.metaflow-datastore[0].datastore_s3_bucket_kms_key_arn

  standard_tags = var.tags
}
