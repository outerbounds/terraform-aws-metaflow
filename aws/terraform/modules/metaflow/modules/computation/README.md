# Computation

This module sets up the resources to run Metaflow steps on AWS Batch. One can modify how many resources
we want to have available, as well as configure autoscaling

This module is not required to use Metaflow, as you can also run steps locally and leverage the Datastore

To read more, see [the Metaflow docs](https://docs.metaflow.org/metaflow-on-aws/metaflow-on-aws#compute)

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_batch_type"></a> [batch\_type](#input\_batch\_type) | AWS Batch Compute Type ('ec2', 'fargate') | `string` | `"ec2"` | no |
| <a name="input_compute_environment_desired_vcpus"></a> [compute\_environment\_desired\_vcpus](#input\_compute\_environment\_desired\_vcpus) | Desired Starting VCPUs for Batch Compute Environment [0-16] for EC2 Batch Compute Environment (ignored for Fargate) | `number` | n/a | yes |
| <a name="input_compute_environment_instance_types"></a> [compute\_environment\_instance\_types](#input\_compute\_environment\_instance\_types) | The instance types for the compute environment as a comma-separated list | `list(string)` | n/a | yes |
| <a name="input_compute_environment_max_vcpus"></a> [compute\_environment\_max\_vcpus](#input\_compute\_environment\_max\_vcpus) | Maximum VCPUs for Batch Compute Environment [16-96] | `number` | n/a | yes |
| <a name="input_compute_environment_min_vcpus"></a> [compute\_environment\_min\_vcpus](#input\_compute\_environment\_min\_vcpus) | Minimum VCPUs for Batch Compute Environment [0-16] for EC2 Batch Compute Environment (ignored for Fargate) | `number` | n/a | yes |
| <a name="input_enable_step_functions"></a> [enable\_step\_functions](#input\_enable\_step\_functions) | If true, apply policies required for step functions | `bool` | `false` | no |
| <a name="input_iam_partition"></a> [iam\_partition](#input\_iam\_partition) | IAM Partition (Select aws-us-gov for AWS GovCloud, otherwise leave as is) | `string` | `"aws"` | no |
| <a name="input_metaflow_step_functions_dynamodb_policy"></a> [metaflow\_step\_functions\_dynamodb\_policy](#input\_metaflow\_step\_functions\_dynamodb\_policy) | IAM policy allowing access to the step functions dynamodb policy | `string` | n/a | yes |
| <a name="input_metaflow_vpc_id"></a> [metaflow\_vpc\_id](#input\_metaflow\_vpc\_id) | ID of the Metaflow VPC this SageMaker notebook instance is to be deployed in | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix given to all AWS resources to differentiate between applications | `string` | n/a | yes |
| <a name="input_resource_suffix"></a> [resource\_suffix](#input\_resource\_suffix) | Suffix given to all AWS resources to differentiate between environment and workspace | `string` | n/a | yes |
| <a name="input_standard_tags"></a> [standard\_tags](#input\_standard\_tags) | The standard tags to apply to every AWS resource. | `map(string)` | n/a | yes |
| <a name="input_subnet1_id"></a> [subnet1\_id](#input\_subnet1\_id) | The first private subnet used for redundancy | `string` | n/a | yes |
| <a name="input_subnet2_id"></a> [subnet2\_id](#input\_subnet2\_id) | The second private subnet used for redundancy | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_METAFLOW_BATCH_JOB_QUEUE"></a> [METAFLOW\_BATCH\_JOB\_QUEUE](#output\_METAFLOW\_BATCH\_JOB\_QUEUE) | AWS Batch Job Queue ARN for Metaflow |
| <a name="output_batch_job_queue_arn"></a> [batch\_job\_queue\_arn](#output\_batch\_job\_queue\_arn) | The ARN of the job queue we'll use to accept Metaflow tasks |
| <a name="output_ecs_execution_role_arn"></a> [ecs\_execution\_role\_arn](#output\_ecs\_execution\_role\_arn) | The IAM role that grants access to ECS and Batch services which we'll use as our Metadata Service API's execution\_role for our Fargate instance |
| <a name="output_ecs_instance_role_arn"></a> [ecs\_instance\_role\_arn](#output\_ecs\_instance\_role\_arn) | This role will be granted access to our S3 Bucket which acts as our blob storage. |
<!-- END_TF_DOCS -->
