# Computation

This module sets up the resources to run Metaflow steps on AWS Batch. One can modify how many resources
we want to have available, as well as configure autoscaling

This module is not required to use Metaflow, as you can also run steps locally, or in a Kubernetes cluster instead.

To read more, see [the Metaflow docs](https://docs.metaflow.org/metaflow-on-aws/metaflow-on-aws#compute)

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_batch_type"></a> [batch\_type](#input\_batch\_type) | AWS Batch Compute Type ('ec2', 'fargate') | `string` | `"ec2"` | no |
| <a name="input_compute_environment_additional_security_group_ids"></a> [compute\_environment\_additional\_security\_group\_ids](#input\_compute\_environment\_additional\_security\_group\_ids) | Additional security group ids to apply to the Batch Compute environment | `list(string)` | `[]` | no |
| <a name="input_compute_environment_allocation_strategy"></a> [compute\_environment\_allocation\_strategy](#input\_compute\_environment\_allocation\_strategy) | Allocation strategy for Batch Compute environment (BEST\_FIT, BEST\_FIT\_PROGRESSIVE, SPOT\_CAPACITY\_OPTIMIZED) | `string` | `"BEST_FIT"` | no |
| <a name="input_compute_environment_desired_vcpus"></a> [compute\_environment\_desired\_vcpus](#input\_compute\_environment\_desired\_vcpus) | Desired Starting VCPUs for Batch Compute Environment [0-16] for EC2 Batch Compute Environment (ignored for Fargate) | `number` | n/a | yes |
| <a name="input_compute_environment_egress_cidr_blocks"></a> [compute\_environment\_egress\_cidr\_blocks](#input\_compute\_environment\_egress\_cidr\_blocks) | CIDR blocks to which egress is allowed from the Batch Compute environment's security group | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_compute_environment_instance_types"></a> [compute\_environment\_instance\_types](#input\_compute\_environment\_instance\_types) | The instance types for the compute environment as a comma-separated list | `list(string)` | n/a | yes |
| <a name="input_compute_environment_max_vcpus"></a> [compute\_environment\_max\_vcpus](#input\_compute\_environment\_max\_vcpus) | Maximum VCPUs for Batch Compute Environment [16-96] | `number` | n/a | yes |
| <a name="input_compute_environment_min_vcpus"></a> [compute\_environment\_min\_vcpus](#input\_compute\_environment\_min\_vcpus) | Minimum VCPUs for Batch Compute Environment [0-16] for EC2 Batch Compute Environment (ignored for Fargate) | `number` | n/a | yes |
| <a name="input_iam_partition"></a> [iam\_partition](#input\_iam\_partition) | IAM Partition (Select aws-us-gov for AWS GovCloud, otherwise leave as is) | `string` | `"aws"` | no |
| <a name="input_launch_template_http_endpoint"></a> [launch\_template\_http\_endpoint](#input\_launch\_template\_http\_endpoint) | Whether the metadata service is available. Can be 'enabled' or 'disabled' | `string` | `"enabled"` | no |
| <a name="input_launch_template_http_put_response_hop_limit"></a> [launch\_template\_http\_put\_response\_hop\_limit](#input\_launch\_template\_http\_put\_response\_hop\_limit) | The desired HTTP PUT response hop limit for instance metadata requests. Can be an integer from 1 to 64 | `number` | `2` | no |
| <a name="input_launch_template_http_tokens"></a> [launch\_template\_http\_tokens](#input\_launch\_template\_http\_tokens) | Whether or not the metadata service requires session tokens, also referred to as Instance Metadata Service Version 2 (IMDSv2). Can be 'optional' or 'required' | `string` | `"optional"` | no |
| <a name="input_launch_template_image_id"></a> [launch\_template\_image\_id](#input\_launch\_template\_image\_id) | AMI id for launch template, defaults to allow AWS Batch to decide | `string` | `null` | no |
| <a name="input_metaflow_vpc_id"></a> [metaflow\_vpc\_id](#input\_metaflow\_vpc\_id) | ID of the Metaflow VPC this SageMaker notebook instance is to be deployed in | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix given to all AWS resources to differentiate between applications | `string` | n/a | yes |
| <a name="input_resource_suffix"></a> [resource\_suffix](#input\_resource\_suffix) | Suffix given to all AWS resources to differentiate between environment and workspace | `string` | n/a | yes |
| <a name="input_standard_tags"></a> [standard\_tags](#input\_standard\_tags) | The standard tags to apply to every AWS resource. | `map(string)` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of private subnets that will be used to create compute instances | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_METAFLOW_BATCH_JOB_QUEUE"></a> [METAFLOW\_BATCH\_JOB\_QUEUE](#output\_METAFLOW\_BATCH\_JOB\_QUEUE) | AWS Batch Job Queue ARN for Metaflow |
| <a name="output_batch_compute_environment_security_group_id"></a> [batch\_compute\_environment\_security\_group\_id](#output\_batch\_compute\_environment\_security\_group\_id) | The ID of the security group attached to the Batch Compute environment. |
| <a name="output_batch_job_queue_arn"></a> [batch\_job\_queue\_arn](#output\_batch\_job\_queue\_arn) | The ARN of the job queue we'll use to accept Metaflow tasks |
| <a name="output_ecs_execution_role_arn"></a> [ecs\_execution\_role\_arn](#output\_ecs\_execution\_role\_arn) | The IAM role that grants access to ECS and Batch services which we'll use as our Metadata Service API's execution\_role for our Fargate instance |
| <a name="output_ecs_instance_role_arn"></a> [ecs\_instance\_role\_arn](#output\_ecs\_instance\_role\_arn) | This role will be granted access to our S3 Bucket which acts as our blob storage. |
<!-- END_TF_DOCS -->
