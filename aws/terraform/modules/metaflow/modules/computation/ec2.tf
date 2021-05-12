resource "aws_launch_template" "cpu" {
  /* To provide a large disk space than the default 8GB for AWS Batch.
     AWS Batch points to this using the latest version, so we can update the disk size here
     and AWS Batch will use that.

     This is used for all Metaflow AWS CPU Batch remote jobs.
  */
  name = "${var.resource_prefix}batch-launch-tmpl-cpu-100gb${var.resource_suffix}"

  # Defines what IAM Role to assume to grant an EC2 instance
  # This role must have a policy to access the kms_key_id used to encrypt the EBS volume
  iam_instance_profile {
    arn = aws_iam_instance_profile.ecs_instance_role.arn
  }

  image_id = jsondecode(data.aws_ssm_parameter.ecs_optimized_cpu_ami.value)["image_id"]

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 100
      delete_on_termination = true
      encrypted             = true
    }
  }

  tags = var.standard_tags
}

resource "aws_launch_template" "gpu" {
  /* To provide a large disk space than the default 8GB for AWS Batch.
     AWS Batch points to this using the latest version, so we can update the disk size here
     and AWS Batch will use that.

     This is used for all Metaflow AWS GPU Batch remote jobs.
  */
  name = "${var.resource_prefix}batch-launch-tmpl-gpu-100gb${var.resource_suffix}"

  # Defines what IAM Role to assume to grant an EC2 instance
  # This role must have a policy to access the kms_key_id used to encrypt the EBS volume
  iam_instance_profile {
    arn = aws_iam_instance_profile.ecs_instance_role.arn
  }

  image_id = jsondecode(data.aws_ssm_parameter.ecs_optimized_gpu_ami.value)["image_id"]

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 100
      delete_on_termination = true
      encrypted             = true
    }
  }

  tags = var.standard_tags
}

resource "aws_security_group" "batch" {
  name        = local.batch_security_group_name
  description = "Allows traffic to pass from the subnet to internet"
  vpc_id      = var.metaflow_vpc_id

  # egress to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.standard_tags
}
