# Step Functions configuration for Metaflow

This module sets up the infrastructure to use AWS Step Functions with Metaflow. 

This builds on top of the functionality provided by the `computation` module, which allows to execute Metaflow step code on AWS Batch. If you use `computation` module alone, the orchestration is done by the Metaflow task scheduler that itself needs to runs somewhere (often, your laptop, or a dedicated server). Step Functions support in Metaflow allows you to replace that scheduler by compiling your Flows to a AWS Step Functions State Machine, and deploying it to AWS.

To read more, see [the Metaflow docs](https://docs.metaflow.org/going-to-production-with-metaflow/scheduling-metaflow-flows)

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_active"></a> [active](#input\_active) | When true step function infrastructure is provisioned. | `bool` | `false` | no |
| <a name="input_batch_job_queue_arn"></a> [batch\_job\_queue\_arn](#input\_batch\_job\_queue\_arn) | Batch job queue arn | `string` | n/a | yes |
| <a name="input_iam_partition"></a> [iam\_partition](#input\_iam\_partition) | IAM Partition (Select aws-us-gov for AWS GovCloud, otherwise leave as is) | `string` | `"aws"` | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix given to all AWS resources to differentiate between applications | `string` | n/a | yes |
| <a name="input_resource_suffix"></a> [resource\_suffix](#input\_resource\_suffix) | Suffix given to all AWS resources to differentiate between environment and workspace | `string` | n/a | yes |
| <a name="input_s3_bucket_arn"></a> [s3\_bucket\_arn](#input\_s3\_bucket\_arn) | arn of the metaflow datastore s3 bucket | `string` | n/a | yes |
| <a name="input_s3_bucket_kms_arn"></a> [s3\_bucket\_kms\_arn](#input\_s3\_bucket\_kms\_arn) | arn of the metaflow datastore s3 bucket's kms key | `string` | n/a | yes |
| <a name="input_standard_tags"></a> [standard\_tags](#input\_standard\_tags) | The standard tags to apply to every AWS resource. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_metaflow_eventbridge_role_arn"></a> [metaflow\_eventbridge\_role\_arn](#output\_metaflow\_eventbridge\_role\_arn) | IAM role for Amazon EventBridge to access AWS Step Functions. |
| <a name="output_metaflow_step_functions_dynamodb_policy"></a> [metaflow\_step\_functions\_dynamodb\_policy](#output\_metaflow\_step\_functions\_dynamodb\_policy) | Policy json allowing access to the step functions dynamodb table. |
| <a name="output_metaflow_step_functions_dynamodb_table_arn"></a> [metaflow\_step\_functions\_dynamodb\_table\_arn](#output\_metaflow\_step\_functions\_dynamodb\_table\_arn) | AWS DynamoDB table arn for tracking AWS Step Functions execution metadata. |
| <a name="output_metaflow_step_functions_dynamodb_table_name"></a> [metaflow\_step\_functions\_dynamodb\_table\_name](#output\_metaflow\_step\_functions\_dynamodb\_table\_name) | AWS DynamoDB table name for tracking AWS Step Functions execution metadata. |
| <a name="output_metaflow_step_functions_role_arn"></a> [metaflow\_step\_functions\_role\_arn](#output\_metaflow\_step\_functions\_role\_arn) | IAM role for AWS Step Functions to access AWS resources (AWS Batch, AWS DynamoDB). |
<!-- END_TF_DOCS -->
