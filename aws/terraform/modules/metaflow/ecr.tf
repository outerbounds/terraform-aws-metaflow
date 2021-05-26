resource "aws_ecr_repository" "metaflow_batch_image" {
  count = var.enable_custom_batch_container_registry ? 1 : 0

  name = local.metaflow_batch_image_name

  tags = var.tags
}
