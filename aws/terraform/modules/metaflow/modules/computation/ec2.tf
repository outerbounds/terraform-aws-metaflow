resource "aws_launch_template" "cpu" {
  count = local.enable_fargate_on_batch ? 0 : 1

  /* To provide a large disk space than the default 8GB for AWS Batch.
     AWS Batch points to this using the latest version, so we can update the disk size here
     and AWS Batch will use that.

     This is used for all Metaflow AWS CPU Batch remote jobs.
  */
  name = "${var.resource_prefix}batch-launch-tmpl-cpu-100gb${var.resource_suffix}"

  # Defines what IAM Role to assume to grant an Amazon EC2 instance
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

/*
 Instance profile is a container for an IAM role. On console when we define role
 instance profile is generated but here we have to manually generate. The instance
 profile passes role info to the instance when it starts.
 Ref:
 https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html
*/
resource "aws_iam_instance_profile" "ecs_instance_role" {
  name = local.ecs_instance_role_name
  role = aws_iam_role.ecs_instance_role.name
}
