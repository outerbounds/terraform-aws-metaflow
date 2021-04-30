locals {
  resource_prefix = length(var.resource_prefix) > 0 ? "${var.resource_prefix}-" : ""
  resource_suffix = length(var.resource_suffix) > 0 ? "-${var.resource_suffix}" : ""

  metaflow_batch_image_name = "${local.resource_prefix}batch${local.resource_suffix}"
}
