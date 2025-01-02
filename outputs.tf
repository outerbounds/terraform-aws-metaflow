output "METAFLOW_BATCH_JOB_QUEUE" {
  value       = var.create_managed_metaflow_metadata_service ? module.metaflow-computation[0].METAFLOW_BATCH_JOB_QUEUE : ""
  description = "AWS Batch Job Queue ARN for Metaflow"
}

output "METAFLOW_DATASTORE_SYSROOT_S3" {
  value       = module.metaflow-datastore[0].METAFLOW_DATASTORE_SYSROOT_S3
  description = "Amazon S3 URL for Metaflow DataStore"
}

output "METAFLOW_DATATOOLS_S3ROOT" {
  value       = module.metaflow-datastore[0].METAFLOW_DATATOOLS_S3ROOT
  description = "Amazon S3 URL for Metaflow DataTools"
}

output "METAFLOW_ECS_S3_ACCESS_IAM_ROLE" {
  value       = aws_iam_role.batch_s3_task_role.arn
  description = "Role for AWS Batch to Access Amazon S3"
}

output "METAFLOW_EVENTS_SFN_ACCESS_IAM_ROLE" {
  value       = var.create_step_functions ? module.metaflow-step-functions[0].metaflow_eventbridge_role_arn : ""
  description = "IAM role for Amazon EventBridge to access AWS Step Functions."
}

output "METAFLOW_SERVICE_INTERNAL_URL" {
  value       = var.create_managed_metaflow_metadata_service ? module.metaflow-metadata-service[0].METAFLOW_SERVICE_INTERNAL_URL : ""
  description = "URL for Metadata Service (Accessible in VPC)"
}

output "METAFLOW_SERVICE_URL" {
  value       = var.create_managed_metaflow_metadata_service ? module.metaflow-metadata-service[0].METAFLOW_SERVICE_URL : ""
  description = "URL for Metadata Service (Accessible in VPC)"
}

output "METAFLOW_SFN_DYNAMO_DB_TABLE" {
  value       = var.create_step_functions ? module.metaflow-step-functions[0].metaflow_step_functions_dynamodb_table_name : ""
  description = "AWS DynamoDB table name for tracking AWS Step Functions execution metadata."
}

output "METAFLOW_SFN_IAM_ROLE" {
  value       = var.create_step_functions ? module.metaflow-step-functions[0].metaflow_step_functions_role_arn : ""
  description = "IAM role for AWS Step Functions to access AWS resources (AWS Batch, AWS DynamoDB)."
}

output "api_gateway_rest_api_id_key_id" {
  value       = var.create_managed_metaflow_metadata_service ? module.metaflow-metadata-service[0].api_gateway_rest_api_id_key_id : ""
  description = "API Gateway Key ID for Metadata Service. Fetch Key from AWS Console [METAFLOW_SERVICE_AUTH_KEY]"
}

output "datastore_s3_bucket_kms_key_arn" {
  value       = module.metaflow-datastore[0].datastore_s3_bucket_kms_key_arn
  description = "The ARN of the KMS key used to encrypt the Metaflow datastore S3 bucket"
}

output "metadata_svc_ecs_task_role_arn" {
  value = var.create_managed_metaflow_metadata_service ? module.metaflow-metadata-service[0].metadata_svc_ecs_task_role_arn : ""
}

output "metaflow_api_gateway_rest_api_id" {
  value       = var.create_managed_metaflow_metadata_service ? module.metaflow-metadata-service[0].api_gateway_rest_api_id : ""
  description = "The ID of the API Gateway REST API we'll use to accept MetaData service requests to forward to the Fargate API instance"
}

output "metaflow_batch_container_image" {
  value       = var.enable_custom_batch_container_registry ? aws_ecr_repository.metaflow_batch_image[0].repository_url : ""
  description = "The ECR repo containing the metaflow batch image"
}

output "metaflow_aws_managed_profile_json" {
  value = jsonencode(
    merge(
      var.enable_custom_batch_container_registry ? {
        "METAFLOW_BATCH_CONTAINER_REGISTRY" = element(split("/", aws_ecr_repository.metaflow_batch_image[0].repository_url), 0),
        "METAFLOW_BATCH_CONTAINER_IMAGE"    = element(split("/", aws_ecr_repository.metaflow_batch_image[0].repository_url), 1)
      } : {},
      var.metadata_service_enable_api_basic_auth && var.create_managed_metaflow_metadata_service ? {
        "METAFLOW_SERVICE_AUTH_KEY" = "## Replace with output from 'aws apigateway get-api-key --api-key ${module.metaflow-metadata-service[0].api_gateway_rest_api_id_key_id} --include-value | grep value' ##"
      } : {},
      var.batch_type == "fargate" ? {
        "METAFLOW_ECS_FARGATE_EXECUTION_ROLE" = module.metaflow-computation[0].ecs_execution_role_arn
      } : {},
      {
        "METAFLOW_DATASTORE_SYSROOT_S3"       = local.METAFLOW_DATASTORE_SYSROOT_S3,
        "METAFLOW_DATATOOLS_S3ROOT"           = var.create_datastore ? module.metaflow-datastore[0].METAFLOW_DATATOOLS_S3ROOT : "",
        "METAFLOW_BATCH_JOB_QUEUE"            = var.create_managed_compute ? module.metaflow-computation[0].METAFLOW_BATCH_JOB_QUEUE : "",
        "METAFLOW_ECS_S3_ACCESS_IAM_ROLE"     = aws_iam_role.batch_s3_task_role.arn
        "METAFLOW_SERVICE_URL"                = var.create_managed_metaflow_metadata_service ? module.metaflow-metadata-service[0].METAFLOW_SERVICE_URL : "",
        "METAFLOW_SERVICE_INTERNAL_URL"       = var.create_managed_metaflow_metadata_service ? module.metaflow-metadata-service[0].METAFLOW_SERVICE_INTERNAL_URL : "",
        "METAFLOW_SFN_IAM_ROLE"               = var.create_step_functions ? module.metaflow-step-functions[0].metaflow_step_functions_role_arn : "",
        "METAFLOW_SFN_STATE_MACHINE_PREFIX"   = var.create_step_functions ? replace("${local.resource_prefix}${local.resource_suffix}", "--", "-") : "",
        "METAFLOW_EVENTS_SFN_ACCESS_IAM_ROLE" = var.create_step_functions ? module.metaflow-step-functions[0].metaflow_eventbridge_role_arn : "",
        "METAFLOW_SFN_DYNAMO_DB_TABLE"        = var.create_step_functions ? module.metaflow-step-functions[0].metaflow_step_functions_dynamodb_table_name : "",
        "METAFLOW_DEFAULT_DATASTORE"          = "s3",
        "METAFLOW_DEFAULT_METADATA"           = "service"
      }
    )
  )
  description = "Metaflow profile JSON object that can be used to communicate with this Metaflow Stack. Store this in `~/.metaflow/config_[stack-name]` and select with `$ export METAFLOW_PROFILE=[stack-name]`."
}

output "metaflow_s3_bucket_name" {
  value       = module.metaflow-datastore[0].s3_bucket_name
  description = "The name of the bucket we'll be using as blob storage"
}

output "metaflow_s3_bucket_arn" {
  value       = local.s3_bucket_arn
  description = "The ARN of the bucket we'll be using as blob storage"
}

output "migration_function_arn" {
  value       = var.create_managed_metaflow_metadata_service ? module.metaflow-metadata-service[0].migration_function_arn : ""
  description = "ARN of DB Migration Function"
}

output "ui_alb_dns_name" {
  value       = (length(module.metaflow-ui) > 0) ? module.metaflow-ui[0].alb_dns_name : ""
  description = "UI ALB DNS name"
}

output "ui_alb_arn" {
  value       = (length(module.metaflow-ui) > 0) ? module.metaflow-ui[0].alb_arn : ""
  description = "UI ALB ARN"
}

output "batch_compute_environment_security_group_id" {
  value       = var.create_managed_metaflow_metadata_service ? module.metaflow-computation[0].batch_compute_environment_security_group_id : ""
  description = "The ID of the security group attached to the Batch Compute environment."
}
