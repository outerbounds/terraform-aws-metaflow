
resource "aws_ecs_task_definition" "ui_backend" {
  family = "${var.resource_prefix}ui_backend${var.resource_suffix}" # Unique name for task definition

  container_definitions = jsonencode([
    {
      name      = "${var.resource_prefix}ui_backend${var.resource_suffix}"
      image     = var.ui_backend_container_image
      essential = true
      cpu       = 2048
      memory    = 16384
      portMappings = [
        {
          containerPort = 8083
          hostPort      = 8083
        }
      ]
      environment = [for k, v in merge(local.default_ui_backend_env_vars, var.extra_ui_backend_env_vars) : { name = k, value = v }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group" : "${aws_cloudwatch_log_group.this.name}"
          "awslogs-region" : "${data.aws_region.current.name}"
          "awslogs-stream-prefix" : "ui_backend"
        }
      }
      command = [
        "/opt/latest/bin/python3",
        "-m",
        "services.ui_backend_service.ui_server"
      ]
    }
  ])

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.metadata_ui_ecs_task_role.arn
  execution_role_arn       = var.fargate_execution_role_arn
  cpu                      = 2048
  memory                   = 16384

  ephemeral_storage {
    size_in_gib = 100
  }

  tags = merge(
    var.standard_tags,
    {
      Metaflow = "true"
    }
  )
}

resource "aws_ecs_service" "ui_backend" {
  name            = "${var.resource_prefix}ui_backend${var.resource_suffix}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.ui_backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.fargate_security_group.id, var.metadata_service_security_group_id]
    assign_public_ip = true
    subnets          = var.subnet_ids
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ui_backend.arn
    container_name   = "${var.resource_prefix}ui_backend${var.resource_suffix}"
    container_port   = 8083
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = var.standard_tags
}
