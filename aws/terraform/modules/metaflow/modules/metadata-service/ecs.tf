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

resource "aws_ecs_task_definition" "this" {
  family = "${var.resource_prefix}service${var.resource_suffix}" # Unique name for task definition

  container_definitions = <<EOF
[
  {
    "name": "${var.resource_prefix}service${var.resource_suffix}",
    "image": "netflixoss/metaflow_metadata_service",
    "essential": true,
    "cpu": 512,
    "memory": 1024,
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      },
      {
        "containerPort": 8082,
        "hostPort": 8082
      }
    ],
    "environment": [
      {"name": "MF_METADATA_DB_HOST", "value": "${replace(var.rds_master_instance_endpoint, ":5432", "")}"},
      {"name": "MF_METADATA_DB_NAME", "value": "metaflow"},
      {"name": "MF_METADATA_DB_PORT", "value": "5432"},
      {"name": "MF_METADATA_DB_PSWD", "value": "${var.database_password}"},
      {"name": "MF_METADATA_DB_USER", "value": "${var.database_username}"}
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${aws_cloudwatch_log_group.this.name}",
            "awslogs-region": "${data.aws_region.current.name}",
            "awslogs-stream-prefix": "metadata"
        }
    }
  }
]
EOF

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.metadata_svc_ecs_task_role.arn
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

resource "aws_ecs_service" "this" {
  name            = "${var.resource_prefix}metadata-service${var.resource_suffix}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.metadata_service_security_group.id]
    assign_public_ip = true
    subnets          = [var.subnet1_id, var.subnet2_id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "${var.resource_prefix}service${var.resource_suffix}"
    container_port   = 8080
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.db_migrate.arn
    container_name   = "${var.resource_prefix}service${var.resource_suffix}"
    container_port   = 8082
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = var.standard_tags
}
