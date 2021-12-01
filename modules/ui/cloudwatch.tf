resource "aws_cloudwatch_log_group" "this" {
  name = "${var.resource_prefix}ui${var.resource_suffix}"

  tags = var.standard_tags
}
