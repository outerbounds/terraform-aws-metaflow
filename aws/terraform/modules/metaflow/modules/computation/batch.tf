resource "aws_batch_compute_environment" "cpu" {
  /* Unique name for compute environment.
     We use compute_environment_name_prefix opposed to just compute_environment_name as batch compute environments must
     be created and destroyed, never edited. This way when we go to make a "modification" we will stand up a new
     batch compute environment with a new unique name and once that succeeds, the old one will be torn down. If we had
     just used compute_environment_name, then there would be a conflict when we went to stand up the new
     compute_environment that had the modifications applied and the process would fail.
  */
  compute_environment_name_prefix = local.cpu_compute_env_prefix_name

  # Give permissions so the batch service can make API calls.
  service_role = aws_iam_role.batch_service_role.arn
  type         = "MANAGED"
  depends_on   = [aws_iam_role_policy_attachment.batch_service_role]

  compute_resources {
    # Give permissions so the ECS container instances can make API call.
    instance_role = aws_iam_instance_profile.ecs_instance_role.arn

    # List of types that can be launched.
    instance_type = var.batch_cpu_instance_types

    # Range of number of CPUs.
    max_vcpus     = var.batch_compute_environment_cpu_max_vcpus
    min_vcpus     = var.batch_compute_environment_cpu_min_vcpus
    desired_vcpus = var.batch_compute_environment_cpu_desired_vcpus

    # Prefers cheap vCPU approaches
    allocation_strategy = "BEST_FIT"

    /* Links to a launch template who has more than the standard 8GB of disk space. So we can download training data.
       Always uses the "default version", which means we can update the Launch Template to a smaller or larger disk size
       and this compute environment will not have to be destroyed and then created to point to a new Launch Template.
    */
    launch_template {
      launch_template_id = aws_launch_template.cpu.id
      version            = aws_launch_template.cpu.latest_version
    }

    # Security group to apply to the instances launched.
    security_group_ids = [
      aws_security_group.batch.id,
    ]

    # Which subnet to launch the instances into.
    subnets = [
      var.subnet_private_1_id,
      var.subnet_private_2_id
    ]

    # Type of instance Amazon EC2 for on-demand. Can use "SPOT" to use unused instances at discount if available
    type = "EC2"

    tags = var.standard_tags
  }

  lifecycle {
    /* From here https://github.com/terraform-providers/terraform-provider-aws/issues/11077#issuecomment-560416740
       helps with "modifying" batch compute environments which requires creating new ones and deleting old ones
       as no inplace modification can be made
    */
    create_before_destroy = true
    # To ensure terraform redeploys do not silently overwrite an up to date desired_vcpus that metaflow may modify
    ignore_changes = [compute_resources.0.desired_vcpus]
  }
}

resource "aws_batch_compute_environment" "large-cpu" {
  /* Unique name for compute environment.
     We use compute_environment_name_prefix opposed to just compute_environment_name as batch compute environments must
     be created and destroyed, never edited. This way when we go to make a "modification" we will stand up a new
     batch compute environment with a new unique name and once that succeeds, the old one will be torn down. If we had
     just used compute_environment_name, then there would be a conflict when we went to stand up the new
     compute_environment that had the modifications applied and the process would fail.
  */
  compute_environment_name_prefix = local.large_cpu_compute_env_prefix_name

  # Give permissions so the batch service can make API calls.
  service_role = aws_iam_role.batch_service_role.arn
  type         = "MANAGED"
  depends_on   = [aws_iam_role_policy_attachment.batch_service_role]

  compute_resources {
    # Give permissions so the ECS container instances can make API call.
    instance_role = aws_iam_instance_profile.ecs_instance_role.arn

    # List of types that can be launched.
    instance_type = var.batch_large_cpu_instance_types

    # Range of number of CPUs.
    max_vcpus     = var.batch_compute_environment_large_cpu_max_vcpus
    min_vcpus     = var.batch_compute_environment_large_cpu_min_vcpus
    desired_vcpus = var.batch_compute_environment_large_cpu_desired_vcpus

    # Prefers cheap vCPU approaches
    allocation_strategy = "BEST_FIT"

    /* Links to a launch template who has more than the standard 8GB of disk space. So we can download training data.
       Always uses the "default version", which means we can update the Launch Template to a smaller or larger disk size
       and this compute environment will not have to be destroyed and then created to point to a new Launch Template.
    */
    launch_template {
      launch_template_id = aws_launch_template.cpu.id
      version            = aws_launch_template.cpu.latest_version
    }

    # Security group to apply to the instances launched.
    security_group_ids = [
      aws_security_group.batch.id,
    ]

    # Which subnet to launch the instances into.
    subnets = [
      var.subnet_private_1_id,
      var.subnet_private_2_id
    ]

    # Type of instance Amazon EC2 for on-demand. Can use "SPOT" to use unused instances at discount if available
    type = "EC2"

    tags = var.standard_tags
  }

  lifecycle {
    /* From here https://github.com/terraform-providers/terraform-provider-aws/issues/11077#issuecomment-560416740
       helps with "modifying" batch compute environments which requires creating new ones and deleting old ones
       as no inplace modification can be made
    */
    create_before_destroy = true
    # To ensure terraform redeploys do not silently overwrite an up to date desired_vcpus that metaflow may modify
    ignore_changes = [compute_resources.0.desired_vcpus]
  }
}

resource "aws_batch_compute_environment" "gpu" {
  /* Unique name for compute environment.
     We use compute_environment_name_prefix opposed to just compute_environment_name as batch compute environments must
     be created and destroyed, never edited. This way when we go to make a "modification" we will stand up a new
     batch compute environment with a new unique name and once that succeeds, the old one will be torn down. If we had
     just used compute_environment_name, then there would be a conflict when we went to stand up the new
     compute_environment that had the modifications applied and the process would fail.
  */
  compute_environment_name_prefix = local.gpu_compute_env_prefix_name

  # Give permissions so the batch service can make API calls.
  service_role = aws_iam_role.batch_service_role.arn
  type         = "MANAGED"
  depends_on   = [aws_iam_role_policy_attachment.batch_service_role]

  compute_resources {
    # Give permissions so the ECS container instances can make API call.
    instance_role = aws_iam_instance_profile.ecs_instance_role.arn

    # List of types that can be launched.
    instance_type = var.batch_gpu_instance_types

    # Range of number of CPUs.
    max_vcpus     = var.batch_compute_environment_gpu_max_vcpus
    min_vcpus     = var.batch_compute_environment_gpu_min_vcpus
    desired_vcpus = var.batch_compute_environment_gpu_desired_vcpus

    # Prefers cheap vCPU approaches
    allocation_strategy = "BEST_FIT"

    /* Links to a launch template who has more than the standard 8GB of disk space. So we can download training data.
       Always uses the "default version", which means we can update the Launch Template to a smaller or larger disk size
       and this compute environment will not have to be destroyed and then created to point to a new Launch Template.
    */
    launch_template {
      launch_template_id = aws_launch_template.gpu.id
      version            = aws_launch_template.gpu.latest_version
    }

    # Security group to apply to the instances launched.
    security_group_ids = [
      aws_security_group.batch.id,
    ]

    # Which subnet to launch the instances into.
    subnets = [
      var.subnet_private_1_id,
      var.subnet_private_2_id
    ]

    # Type of instance Amazon EC2 for on-demand. Can use "SPOT" to use unused instances at discount if available
    type = "EC2"

    tags = var.standard_tags
  }

  lifecycle {
    /* From here https://github.com/terraform-providers/terraform-provider-aws/issues/11077#issuecomment-560416740
       helps with "modifying" batch compute environments which requires creating new ones and deleting old ones
       as no inplace modification can be made
    */
    create_before_destroy = true
    # To ensure terraform redeploys do not silently overwrite an up to date desired_vcpus that metaflow may modify
    ignore_changes = [compute_resources.0.desired_vcpus]
  }
}

resource "aws_batch_job_queue" "this" {
  name     = local.batch_queue_name
  state    = "ENABLED"
  priority = 1
  compute_environments = [
    aws_batch_compute_environment.cpu.arn,
    aws_batch_compute_environment.large-cpu.arn,
    aws_batch_compute_environment.gpu.arn
  ]

  tags = var.standard_tags
}
