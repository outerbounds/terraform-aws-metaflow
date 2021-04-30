resource "aws_ecr_repository" "metaflow_batch_image" {
  name = local.metaflow_batch_image_name

  tags = var.tags
}
