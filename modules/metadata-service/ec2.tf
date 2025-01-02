resource "aws_security_group" "metadata_service_security_group" {
  name        = local.metadata_service_security_group_name
  description = "Security Group for Fargate which runs the Metadata Service."
  vpc_id      = var.metaflow_vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.vpc_cidr_blocks
    description = "Allow API calls internally"
  }

  ingress {
    from_port   = 8082
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = var.vpc_cidr_blocks
    description = "Allow API calls internally"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    self        = true
    description = "Internal communication"
  }

  # egress to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # all
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all external communication"
  }

  tags = merge(
    var.standard_tags,
    {
      Metaflow = "true"
    }
  )
}

resource "aws_lb" "this" {
  name               = "${var.resource_prefix}nlb${var.resource_suffix}"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.subnet_ids

  tags = var.standard_tags
}

resource "aws_lb_target_group" "this" {
  name        = "${var.resource_prefix}mdtg${var.resource_suffix}"
  port        = 8080
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.metaflow_vpc_id

  health_check {
    protocol            = "TCP"
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = var.standard_tags
}

resource "aws_lb_target_group" "db_migrate" {
  name        = "${var.resource_prefix}dbtg${var.resource_suffix}"
  port        = 8082
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.metaflow_vpc_id

  health_check {
    protocol            = "TCP"
    port                = 8080
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = var.standard_tags
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.id
  }
}

resource "aws_lb_listener" "db_migrate" {
  load_balancer_arn = aws_lb.this.arn
  port              = "8082"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.db_migrate.id
  }
}
