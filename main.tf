module "metaflow-datastore" {
  source = "./modules/datastore"

  resource_prefix = local.resource_prefix
  resource_suffix = local.resource_suffix

  metadata_service_security_group_id = module.metaflow-metadata-service.metadata_service_security_group_id
  metaflow_vpc_id                    = var.vpc_id
  subnet1_id                         = var.subnet1_id
  subnet2_id                         = var.subnet2_id
  db_identifier_prefix               = var.db_identifier_prefix
  db_instance_type                   = var.db_instance_type
  db_engine_version                  = var.db_engine_version
  db_parameters                      = var.db_parameters
  db_multi_az                        = var.db_multi_az

  apply_immediately              = var.apply_immediately
  maintenance_window             = var.maintenance_window
  ca_cert_identifier             = var.ca_cert_identifier
  db_allow_major_version_upgrade = var.db_allow_major_version_upgrade

  standard_tags    = var.tags
  db_instance_tags = var.db_instance_tags

  s3_bucket_name     = var.s3_bucket_name
  s3_bucket_tags     = var.s3_bucket_tags
  bucket_key_enabled = var.bucket_key_enabled
}

module "metaflow-metadata-service" {
  source = "./modules/metadata-service"

  resource_prefix = local.resource_prefix
  resource_suffix = local.resource_suffix

  ecs_cluster_settings             = var.ecs_cluster_settings
  load_balancer_name_prefix        = var.load_balancer_name_prefix
  access_list_cidr_blocks          = var.access_list_cidr_blocks
  api_basic_auth                   = var.api_basic_auth
  database_name                    = module.metaflow-datastore.database_name
  database_password                = module.metaflow-datastore.database_password
  database_username                = module.metaflow-datastore.database_username
  database_ssl_mode                = var.database_ssl_mode
  database_ssl_cert_path           = var.database_ssl_cert_path
  database_ssl_key_path            = var.database_ssl_key_path
  database_ssl_root_cert           = var.database_ssl_root_cert
  db_migrate_lambda_zip_file       = var.db_migrate_lambda_zip_file
  db_migrate_lambda_runtime        = var.db_migrate_lambda_runtime
  datastore_s3_bucket_kms_key_arn  = module.metaflow-datastore.datastore_s3_bucket_kms_key_arn
  fargate_execution_role_arn       = module.metaflow-computation.ecs_execution_role_arn
  iam_partition                    = var.iam_partition
  metadata_service_container_image = local.metadata_service_container_image
  metaflow_vpc_id                  = var.vpc_id
  rds_master_instance_endpoint     = module.metaflow-datastore.rds_master_instance_endpoint
  s3_bucket_arn                    = module.metaflow-datastore.s3_bucket_arn
  subnet1_id                       = var.subnet1_id
  subnet2_id                       = var.subnet2_id
  vpc_cidr_blocks                  = var.vpc_cidr_blocks
  with_public_ip                   = var.with_public_ip

  standard_tags = var.tags
}

module "metaflow-ui" {
  source = "./modules/ui"

  resource_prefix = local.resource_prefix
  resource_suffix = local.resource_suffix

  ecs_cluster_settings            = var.ecs_cluster_settings
  load_balancer_name_prefix       = var.load_balancer_name_prefix
  database_name                   = module.metaflow-datastore.database_name
  database_password               = module.metaflow-datastore.database_password
  database_username               = module.metaflow-datastore.database_username
  datastore_s3_bucket_kms_key_arn = module.metaflow-datastore.datastore_s3_bucket_kms_key_arn
  fargate_execution_role_arn      = module.metaflow-computation.ecs_execution_role_arn
  iam_partition                   = var.iam_partition
  metaflow_vpc_id                 = var.vpc_id
  rds_master_instance_endpoint    = module.metaflow-datastore.rds_master_instance_endpoint
  s3_bucket_arn                   = module.metaflow-datastore.s3_bucket_arn
  subnet1_id                      = var.subnet1_id
  subnet2_id                      = var.subnet2_id
  ui_backend_container_image      = local.metadata_service_container_image
  ui_static_container_image       = local.ui_static_container_image
  alb_internal                    = var.ui_alb_internal
  ui_allow_list                   = var.ui_allow_list
  lb_access_log_bucket            = var.enable_lb_access_logging ? aws_s3_bucket.elb_access_logs_bucket[0].id : null

  cognito_user_pool_arn       = var.ui_cognito_user_pool_arn
  cognito_user_pool_client_id = var.ui_cognito_user_pool_client_id
  cognito_user_pool_domain    = var.ui_cognito_user_pool_domain

  METAFLOW_DATASTORE_SYSROOT_S3      = module.metaflow-datastore.METAFLOW_DATASTORE_SYSROOT_S3
  certificate_arn                    = var.ui_certificate_arn
  metadata_service_security_group_id = module.metaflow-metadata-service.metadata_service_security_group_id

  extra_ui_static_env_vars  = var.extra_ui_static_env_vars
  extra_ui_backend_env_vars = var.extra_ui_backend_env_vars
  standard_tags             = var.tags
}

moved {
  from = module.metaflow-ui[0]
  to   = module.metaflow-ui
}

module "metaflow-computation" {
  source = "./modules/computation"

  resource_prefix = local.resource_prefix
  resource_suffix = local.resource_suffix

  batch_cluster_name                          = var.batch_cluster_name
  batch_type                                  = var.batch_type
  compute_environment_desired_vcpus           = var.compute_environment_desired_vcpus
  compute_environment_instance_types          = var.compute_environment_instance_types
  compute_environment_max_vcpus               = var.compute_environment_max_vcpus
  compute_environment_min_vcpus               = var.compute_environment_min_vcpus
  compute_environment_egress_cidr_blocks      = var.compute_environment_egress_cidr_blocks
  iam_partition                               = var.iam_partition
  metaflow_vpc_id                             = var.vpc_id
  subnet1_id                                  = var.subnet1_id
  subnet2_id                                  = var.subnet2_id
  launch_template_http_endpoint               = var.launch_template_http_endpoint
  launch_template_http_tokens                 = var.launch_template_http_tokens
  launch_template_http_put_response_hop_limit = var.launch_template_http_put_response_hop_limit

  standard_tags = var.tags
}

module "metaflow-step-functions" {
  source = "./modules/step-functions"

  resource_prefix = local.resource_prefix
  resource_suffix = local.resource_suffix

  active              = var.enable_step_functions
  batch_job_queue_arn = module.metaflow-computation.METAFLOW_BATCH_JOB_QUEUE
  iam_partition       = var.iam_partition
  s3_bucket_arn       = module.metaflow-datastore.s3_bucket_arn
  s3_bucket_kms_arn   = module.metaflow-datastore.datastore_s3_bucket_kms_key_arn

  standard_tags = var.tags
}
