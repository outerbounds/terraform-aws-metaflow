/*
 A subnet is attached to an availability zone so for db redundancy and
 performance we need to define additional subnet(s) and aws_db_subnet_group
 is how we define this.
*/
resource "aws_db_subnet_group" "this" {
  name       = local.pg_subnet_group_name
  subnet_ids = [var.subnet1_id, var.subnet2_id]

  tags = merge(
    var.standard_tags,
    {
      Name     = local.pg_subnet_group_name
      Metaflow = "true"
    }
  )
}

/*
 Define a new firewall for our database instance.
*/
resource "aws_security_group" "rds_security_group" {
  name   = local.rds_security_group_name
  vpc_id = var.metaflow_vpc_id

  # ingress only from port 5432
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.metadata_service_security_group_id]
  }

  # egress to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.standard_tags
}

resource "random_password" "this" {
  length  = 64
  special = true
  # redefines the `special` variable by removing the `@`
  # this documentation https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Limits.html
  # shows that the `/`, `"`, `@` and ` ` cannot be used in the password
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_pet" "final_snapshot_id" {}

locals {
  use_aurora             = length(regexall("^aurora-", var.db_engine)) > 0
  parameter_group_family = "${var.db_engine}${split(".", var.db_engine_version)[0]}"
}

resource "aws_rds_cluster" "this" {
  count              = local.use_aurora ? 1 : 0
  cluster_identifier = local.rds_db_identifier
  kms_key_id         = aws_kms_key.rds.arn
  engine             = var.db_engine

  database_name        = var.db_name
  master_username      = var.db_username
  master_password      = random_password.this.result
  db_subnet_group_name = aws_db_subnet_group.this.id

  engine_version    = var.db_engine_version
  storage_encrypted = true

  final_snapshot_identifier = local.rds_final_snapshot_identifier # Snapshot upon delete
  vpc_security_group_ids    = [aws_security_group.rds_security_group.id]

  apply_immediately            = var.apply_immediately
  preferred_maintenance_window = length(var.maintenance_window) > 0 ? var.maintenance_window : null

  tags = merge(
    var.standard_tags,
    var.db_instance_tags,
    {
      Name     = local.rds_db_identifier
      Metaflow = "true"
    }
  )
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = local.use_aurora ? 1 : 0
  identifier         = "${local.rds_db_identifier}-${count.index}"
  cluster_identifier = aws_rds_cluster.this[0].id
  instance_class     = var.db_instance_type
  engine             = aws_rds_cluster.this[0].engine
  engine_version     = aws_rds_cluster.this[0].engine_version
  ca_cert_identifier = length(var.ca_cert_identifier) > 0 ? var.ca_cert_identifier : null

  apply_immediately            = var.apply_immediately
  preferred_maintenance_window = length(var.maintenance_window) > 0 ? var.maintenance_window : null
}

/*
 Define rds db instance.
*/
resource "aws_db_instance" "this" {
  count                     = local.use_aurora ? 0 : 1
  publicly_accessible       = false
  allocated_storage         = 20    # Allocate 20GB
  storage_type              = "gp2" # general purpose SSD
  storage_encrypted         = true
  kms_key_id                = aws_kms_key.rds.arn
  engine                    = var.db_engine
  engine_version            = var.db_engine_version
  instance_class            = var.db_instance_type    # Hardware configuration
  identifier                = local.rds_db_identifier # used for dns hostname needs to be customer unique in region
  db_name                   = var.db_name             # unique id for CLI commands (name of DB table which is why we're not adding the prefix as no conflicts will occur and the API expects this table name)
  snapshot_identifier       = var.db_snapshot_identifier
  username                  = var.db_username
  password                  = random_password.this.result
  db_subnet_group_name      = aws_db_subnet_group.this.id
  max_allocated_storage     = 1000 # Upper limit of automatic scaled storage
  multi_az                  = var.db_multi_az
  final_snapshot_identifier = local.rds_final_snapshot_identifier # Snapshot upon delete
  vpc_security_group_ids    = [aws_security_group.rds_security_group.id]
  ca_cert_identifier        = var.ca_cert_identifier
  parameter_group_name      = length(var.db_parameters) > 0 ? aws_db_parameter_group.this[0].name : "default.${local.parameter_group_family}"

  apply_immediately           = var.apply_immediately
  maintenance_window          = length(var.maintenance_window) > 0 ? var.maintenance_window : null
  auto_minor_version_upgrade  = var.db_auto_minor_version_upgrade
  allow_major_version_upgrade = var.db_allow_major_version_upgrade

  tags = merge(
    var.standard_tags,
    var.db_instance_tags,
    {
      Name     = local.rds_db_identifier
      Metaflow = "true"
    }
  )
}

resource "aws_db_parameter_group" "this" {
  count  = length(var.db_parameters) > 0 ? 1 : 0
  name   = "${local.rds_db_identifier}-${local.parameter_group_family}"
  family = local.parameter_group_family

  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      apply_method = "immediate"
      name         = parameter.key
      value        = parameter.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
