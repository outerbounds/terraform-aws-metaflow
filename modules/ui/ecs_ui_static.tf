

resource "aws_ecs_task_definition" "ui_static" {
  family = "${var.resource_prefix}ui_static${var.resource_suffix}" # Unique name for task definition

  container_definitions = jsonencode([
    {
      name      = "${var.resource_prefix}ui_static${var.resource_suffix}"
      image     = var.ui_static_container_image
      essential = true
      cpu       = 512
      memory    = 1024
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      environment = [for k, v in merge(local.default_ui_static_env_vars, var.extra_ui_static_env_vars) : { name = k, value = v }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group" : "${aws_cloudwatch_log_group.this.name}"
          "awslogs-region" : "${data.aws_region.current.name}"
          "awslogs-stream-prefix" : "ui_static"
        }
      }
    }
  ])

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.metadata_ui_ecs_task_role.arn
  execution_role_arn       = var.fargate_execution_role_arn
  cpu                      = 512
  memory                   = 1024

  tags = merge(
    var.standard_tags,
    {
      Metaflow = "true"
    }
  )
}

resource "aws_ecs_service" "ui_static" {
  name            = "${var.resource_prefix}ui_static${var.resource_suffix}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.ui_static.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.fargate_security_group.id]
    assign_public_ip = true
    subnets          = var.subnet_ids
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ui_static.arn
    container_name   = "${var.resource_prefix}ui_static${var.resource_suffix}"
    container_port   = 3000
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = var.standard_tags
}
