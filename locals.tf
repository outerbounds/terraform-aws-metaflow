module "metaflow-common" {
  source = "./modules/common"
}

data "aws_iam_role" "batch_s3_task_role" {
  name  = var.batch_s3_task_role_name
  count = var.batch_s3_task_role_name == "" ? 0 : 1
}

locals {
  resource_prefix = length(var.resource_prefix) > 0 ? "${var.resource_prefix}-" : ""
  resource_suffix = length(var.resource_suffix) > 0 ? "-${var.resource_suffix}" : ""

  aws_region     = data.aws_region.current.name
  aws_account_id = data.aws_caller_identity.current.account_id

  batch_s3_task_role_name   = "${local.resource_prefix}batch_s3_task_role${local.resource_suffix}"
  metaflow_batch_image_name = "${local.resource_prefix}batch${local.resource_suffix}"
  metadata_service_container_image = (
    var.metadata_service_container_image == "" ?
    module.metaflow-common.default_metadata_service_container_image :
    var.metadata_service_container_image
  )
  ui_static_container_image = (
    var.ui_static_container_image == "" ?
    module.metaflow-common.default_ui_static_container_image :
    var.ui_static_container_image
  )

  metadata_svc_ecs_task_role_id  = var.metadata_svc_ecs_task_role_name == "" ? aws_iam_role.metadata_svc_ecs_task_role[0].id : data.metadata_svc_ecs_task_role.id
  metadata_svc_ecs_task_role_arn = var.metadata_svc_ecs_task_role_name == "" ? aws_iam_role.metadata_svc_ecs_task_role[0].arn : data.metadata_svc_ecs_task_role.arn

  batch_s3_task_role_id  = var.batch_s3_task_role_name == "" ? aws_iam_role.batch_s3_task_role[0].id : data.batch_s3_task_role.id
  batch_s3_task_role_arn = var.batch_s3_task_role_name == "" ? aws_iam_role.batch_s3_task_role[0].arn : data.batch_s3_task_role.arn
}
