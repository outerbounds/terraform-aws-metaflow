output "METAFLOW_DATASTORE_SYSROOT_S3" {
  value       = module.metaflow-datastore.METAFLOW_DATASTORE_SYSROOT_S3
  description = "Amazon S3 URL for Metaflow DataStore"
}

output "METAFLOW_DATATOOLS_S3ROOT" {
  value       = module.metaflow-datastore.METAFLOW_DATATOOLS_S3ROOT
  description = "Amazon S3 URL for Metaflow DataTools"
}

output "METAFLOW_BATCH_JOB_QUEUE" {
  value       = module.metaflow-computation.METAFLOW_BATCH_JOB_QUEUE
  description = "AWS Batch Job Queue ARN for Metaflow"
}

output "METAFLOW_ECS_S3_ACCESS_IAM_ROLE" {
  value       = module.metaflow-computation.METAFLOW_ECS_S3_ACCESS_IAM_ROLE
  description = "Role for AWS Batch to Access Amazon S3 ARN"
}

output "METAFLOW_SERVICE_URL" {
  value       = module.metaflow-metadata-service.METAFLOW_SERVICE_URL
  description = "URL for Metadata Service (Accessible in VPC)"
}

output "METAFLOW_SERVICE_INTERNAL_URL" {
  value       = module.metaflow-metadata-service.METAFLOW_SERVICE_INTERNAL_URL
  description = "URL for Metadata Service (Accessible in VPC)"
}

output "METAFLOW_SFN_IAM_ROLE" {
  value       = module.metaflow-step-functions.metaflow_step_functions_role_arn
  description = "IAM role for AWS Step Functions to access AWS resources (AWS Batch, AWS DynamoDB)."
}

output "METAFLOW_EVENTS_SFN_ACCESS_IAM_ROLE" {
  value       = module.metaflow-step-functions.metaflow_eventbridge_role_arn
  description = "IAM role for Amazon EventBridge to access AWS Step Functions."
}

output "METAFLOW_SFN_DYNAMO_DB_TABLE" {
  value       = module.metaflow-step-functions.metaflow_step_functions_dynamodb_table_name
  description = "AWS DynamoDB table name for tracking AWS Step Functions execution metadata."
}

output "metaflow_profile_json" {
  value = jsonencode(
    merge(
      var.enable_custom_batch_container_registry ? {
        "METAFLOW_BATCH_CONTAINER_REGISTRY" = element(split("/", aws_ecr_repository.metaflow_batch_image[0].repository_url), 0),
        "METAFLOW_BATCH_CONTAINER_IMAGE"    = element(split("/", aws_ecr_repository.metaflow_batch_image[0].repository_url), 1)
      } : {},
      {
        "METAFLOW_DATASTORE_SYSROOT_S3"       = module.metaflow-datastore.METAFLOW_DATASTORE_SYSROOT_S3,
        "METAFLOW_DATATOOLS_S3ROOT"           = module.metaflow-datastore.METAFLOW_DATATOOLS_S3ROOT,
        "METAFLOW_BATCH_JOB_QUEUE"            = module.metaflow-computation.METAFLOW_BATCH_JOB_QUEUE,
        "METAFLOW_ECS_S3_ACCESS_IAM_ROLE"     = module.metaflow-computation.METAFLOW_ECS_S3_ACCESS_IAM_ROLE,
        "METAFLOW_SERVICE_URL"                = module.metaflow-metadata-service.METAFLOW_SERVICE_URL,
        "METAFLOW_SERVICE_INTERNAL_URL"       = module.metaflow-metadata-service.METAFLOW_SERVICE_INTERNAL_URL,
        "METAFLOW_SFN_IAM_ROLE"               = module.metaflow-step-functions.metaflow_step_functions_role_arn,
        "METAFLOW_SFN_STATE_MACHINE_PREFIX"   = replace("${local.resource_prefix}${local.resource_suffix}", "--", "-"),
        "METAFLOW_EVENTS_SFN_ACCESS_IAM_ROLE" = module.metaflow-step-functions.metaflow_eventbridge_role_arn,
        "METAFLOW_SFN_DYNAMO_DB_TABLE"        = module.metaflow-step-functions.metaflow_step_functions_dynamodb_table_name,
        "METAFLOW_DEFAULT_DATASTORE"          = "s3",
        "METAFLOW_DEFAULT_METADATA"           = "service"
      }
    )
  )
  description = "Metaflow profile JSON object that can be used to communicate with this Metaflow Stack. Store this in `~/.metaflow/config_[stack-name]` and select with `$ export METAFLOW_PROFILE=[stack-name]`."
}

output "metaflow_s3_bucket_name" {
  value       = module.metaflow-datastore.s3_bucket_name
  description = "The name of the bucket we'll be using as blob storage"
}

output "metaflow_s3_bucket_arn" {
  value       = module.metaflow-datastore.s3_bucket_arn
  description = "The ARN of the bucket we'll be using as blob storage"
}

output "metaflow_s3_bucket_policy" {
  value       = module.metaflow-datastore.metaflow_s3_policy_arn
  description = "Policy grants access to the Metaflow S3 bucket used for blob storage by the Datastore"
}

output "metaflow_s3_bucket_kms_key_policy" {
  value       = module.metaflow-datastore.metaflow_kms_s3_policy_arn
  description = "The ARN of the KMS key used to encrypt the Metaflow datastore S3 bucket"
}

output "metaflow_api_gateway_rest_api_id" {
  value       = module.metaflow-metadata-service.api_gateway_rest_api_id
  description = "The ID of the API Gateway REST API we'll use to accept MetaData service requests to forward to the Fargate API instance"
}

output "metaflow_batch_container_image" {
  value       = var.enable_custom_batch_container_registry ? aws_ecr_repository.metaflow_batch_image[0].repository_url : ""
  description = "The ECR repo containing the metaflow batch image"
}

output "metaflow_kms_s3_policy_arn" {
  value       = module.metaflow-datastore.metaflow_kms_s3_policy_arn
  description = "policy for accessing kms key associated with the metaflow s3 bucket"
}
