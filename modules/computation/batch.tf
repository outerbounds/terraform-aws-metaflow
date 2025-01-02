resource "aws_batch_compute_environment" "this" {
  /* Unique name for compute environment.
     We use compute_environment_name_prefix opposed to just compute_environment_name as batch compute environments must
     be created and destroyed, never edited. This way when we go to make a "modification" we will stand up a new
     batch compute environment with a new unique name and once that succeeds, the old one will be torn down. If we had
     just used compute_environment_name, then there would be a conflict when we went to stand up the new
     compute_environment that had the modifications applied and the process would fail.
  */
  compute_environment_name_prefix = local.compute_env_prefix_name

  # Give permissions so the batch service can make API calls.
  service_role = aws_iam_role.batch_execution_role.arn
  type         = "MANAGED"

  # On destroy, this avoids removing these policies below until compute environments are destroyed
  depends_on = [
    aws_iam_role_policy.grant_iam_pass_role,
    aws_iam_role_policy.grant_custom_access_policy,
    aws_iam_role_policy.grant_iam_custom_policies,
    aws_iam_role_policy.grant_ec2_custom_policies,
  ]

  compute_resources {
    # Give permissions so the ECS container instances can make API call.
    instance_role = !local.enable_fargate_on_batch ? aws_iam_instance_profile.ecs_instance_role.arn : null

    # List of types that can be launched.
    instance_type = !local.enable_fargate_on_batch ? var.compute_environment_instance_types : null

    # Range of number of CPUs.
    max_vcpus     = var.compute_environment_max_vcpus
    min_vcpus     = !local.enable_fargate_on_batch ? var.compute_environment_min_vcpus : null
    desired_vcpus = !local.enable_fargate_on_batch ? var.compute_environment_desired_vcpus : null

    # Prefers cheap vCPU approaches
    allocation_strategy = !local.enable_fargate_on_batch ? var.compute_environment_allocation_strategy : null

    /* Links to a launch template who has more than the standard 8GB of disk space. So we can download training data.
       Always uses the "default version", which means we can update the Launch Template to a smaller or larger disk size
       and this compute environment will not have to be destroyed and then created to point to a new Launch Template.
    */
    dynamic "launch_template" {
      for_each = aws_launch_template.cpu
      content {
        launch_template_id = launch_template.value.id
        version            = launch_template.value.latest_version
      }
    }

    # Security group to apply to the instances launched.
    security_group_ids = concat([
      aws_security_group.this.id,
    ], var.compute_environment_additional_security_group_ids)

    # Which subnet to launch the instances into.
    subnets = var.subnet_ids

    # Type of instance Amazon EC2 for on-demand. Can use "SPOT" to use unused instances at discount if available
    type = local.enable_fargate_on_batch ? "FARGATE" : "EC2"

    tags = !local.enable_fargate_on_batch ? var.standard_tags : null
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
  compute_environment_order {
    compute_environment = aws_batch_compute_environment.this.arn
    order               = 1
  }

  tags = var.standard_tags
}
