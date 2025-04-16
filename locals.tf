module "metaflow-common" {
  source = "./modules/common"
}

locals {
  resource_prefix = length(var.resource_prefix) > 0 ? "${var.resource_prefix}-" : ""
  resource_suffix = length(var.resource_suffix) > 0 ? "-${var.resource_suffix}" : ""

  aws_region     = data.aws_region.current.name
  aws_account_id = data.aws_caller_identity.current.account_id

  aws_region_split = split("-", local.aws_region)
  aws_region_short = "${local.aws_region_split[0]}${substr(local.aws_region_split[1], 0, 1)}${local.aws_region_split[2]}"

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
  lb_access_logs_bucket_name = "${local.resource_prefix}elb-access-logs-${local.aws_account_id}-${local.aws_region_short}"
}
