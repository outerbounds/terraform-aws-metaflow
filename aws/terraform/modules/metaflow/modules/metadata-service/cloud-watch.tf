resource "aws_cloudwatch_log_group" "this" {
  name = "${var.resource_prefix}metadata${var.resource_suffix}"

  tags = var.standard_tags
}
