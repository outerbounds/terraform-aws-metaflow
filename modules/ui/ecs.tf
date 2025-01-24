resource "aws_ecs_cluster" "this" {
  name = local.ecs_cluster_name

  dynamic "setting" {
    for_each = var.ecs_cluster_settings
    content {
      name  = setting.key
      value = setting.value
    }

  }

  tags = merge(
    var.standard_tags,
    {
      Name     = local.ecs_cluster_name
      Metaflow = "true"
    }
  )
}
