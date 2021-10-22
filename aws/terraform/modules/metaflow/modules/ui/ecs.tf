resource "aws_ecs_cluster" "this" {
  name = local.ecs_cluster_name

  tags = merge(
    var.standard_tags,
    {
      Name     = local.ecs_cluster_name
      Metaflow = "true"
    }
  )
}
