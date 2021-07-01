module "metaflow-datastore" {
  source = "./modules/datastore"

  resource_prefix = local.resource_prefix
  resource_suffix = local.resource_suffix

  ecs_execution_role_arn             = module.metaflow-computation.ecs_execution_role_arn
  ecs_instance_role_arn              = module.metaflow-computation.ecs_instance_role_arn
  metadata_service_security_group_id = module.metaflow-metadata-service.metadata_service_security_group_id
  metaflow_vpc_id                    = var.vpc_id
  subnet1_id                         = var.subnet1_id
  subnet2_id                         = var.subnet2_id

  standard_tags = var.tags
}

module "metaflow-metadata-service" {
  source = "./modules/metadata-service"

  resource_prefix = local.resource_prefix
  resource_suffix = local.resource_suffix

  access_list_cidr_blocks         = var.access_list_cidr_blocks
  api_basic_auth                  = var.api_basic_auth
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
  vpc_cidr_block                  = var.vpc_cidr_block

  standard_tags = var.tags
}

module "metaflow-computation" {
  source = "./modules/computation"

  resource_prefix = local.resource_prefix
  resource_suffix = local.resource_suffix

  batch_type                              = var.batch_type
  compute_environment_desired_vcpus       = var.compute_environment_desired_vcpus
  compute_environment_instance_types      = var.compute_environment_instance_types
  compute_environment_max_vcpus           = var.compute_environment_max_vcpus
  compute_environment_min_vcpus           = var.compute_environment_min_vcpus
  enable_step_functions                   = var.enable_step_functions
  iam_partition                           = var.iam_partition
  metaflow_step_functions_dynamodb_policy = module.metaflow-step-functions.metaflow_step_functions_dynamodb_policy
  metaflow_vpc_id                         = var.vpc_id
  subnet1_id                              = var.subnet1_id
  subnet2_id                              = var.subnet2_id

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
