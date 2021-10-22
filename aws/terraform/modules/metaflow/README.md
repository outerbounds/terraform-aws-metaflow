# Metaflow Terraform module

Provides the core functionality for Metaflow which includes:

- on demand processing (`computation`)
- blob and tabular storage (`datastore`)
- an API to record and query past executions (`metadata-service`)
- orchestrated processing (`step-functions`)
- other bits of infra like Amazon Elastic Container Registry (ECR) to hold the Docker image we wish to use with Metaflow.

This module is composed of submodules which break up the responsibility into logical parts listed above.
You can either use this high-level module, or submodules individually. See each module's corresponding `README.md` for more details.

This module requires an Amazon VPC to be set up by the module user beforehand. The output of the project `infra` is an example configuration of an Amazon VPC that can be passed to this module.

<!-- BEGIN_TF_DOCS -->
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_metaflow-computation"></a> [metaflow-computation](#module\_metaflow-computation) | ./modules/computation | n/a |
| <a name="module_metaflow-datastore"></a> [metaflow-datastore](#module\_metaflow-datastore) | ./modules/datastore | n/a |
| <a name="module_metaflow-metadata-service"></a> [metaflow-metadata-service](#module\_metaflow-metadata-service) | ./modules/metadata-service | n/a |
| <a name="module_metaflow-step-functions"></a> [metaflow-step-functions](#module\_metaflow-step-functions) | ./modules/step-functions | n/a |
| <a name="module_metaflow-ui"></a> [metaflow-ui](#module\_metaflow-ui) | ./modules/ui | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_list_cidr_blocks"></a> [access\_list\_cidr\_blocks](#input\_access\_list\_cidr\_blocks) | List of CIDRs we want to grant access to our Metaflow Metadata Service. Usually this is our VPN's CIDR blocks. | `list(string)` | `[]` | no |
| <a name="input_api_basic_auth"></a> [api\_basic\_auth](#input\_api\_basic\_auth) | Enable basic auth for API Gateway? (requires key export) | `bool` | `true` | no |
| <a name="input_batch_type"></a> [batch\_type](#input\_batch\_type) | AWS Batch Compute Type ('ec2', 'fargate') | `string` | `"ec2"` | no |
| <a name="input_compute_environment_desired_vcpus"></a> [compute\_environment\_desired\_vcpus](#input\_compute\_environment\_desired\_vcpus) | Desired Starting VCPUs for Batch Compute Environment [0-16] for EC2 Batch Compute Environment (ignored for Fargate) | `number` | `8` | no |
| <a name="input_compute_environment_instance_types"></a> [compute\_environment\_instance\_types](#input\_compute\_environment\_instance\_types) | The instance types for the compute environment | `list(string)` | <pre>[<br>  "c4.large",<br>  "c4.xlarge",<br>  "c4.2xlarge",<br>  "c4.4xlarge",<br>  "c4.8xlarge"<br>]</pre> | no |
| <a name="input_compute_environment_max_vcpus"></a> [compute\_environment\_max\_vcpus](#input\_compute\_environment\_max\_vcpus) | Maximum VCPUs for Batch Compute Environment [16-96] | `number` | `64` | no |
| <a name="input_compute_environment_min_vcpus"></a> [compute\_environment\_min\_vcpus](#input\_compute\_environment\_min\_vcpus) | Minimum VCPUs for Batch Compute Environment [0-16] for EC2 Batch Compute Environment (ignored for Fargate) | `number` | `8` | no |
| <a name="input_enable_custom_batch_container_registry"></a> [enable\_custom\_batch\_container\_registry](#input\_enable\_custom\_batch\_container\_registry) | Provisions infrastructure for custom Amazon ECR container registry if enabled | `bool` | `false` | no |
| <a name="input_enable_step_functions"></a> [enable\_step\_functions](#input\_enable\_step\_functions) | Provisions infrastructure for step functions if enabled | `bool` | n/a | yes |
| <a name="input_extra_ui_backend_env_vars"></a> [extra\_ui\_backend\_env\_vars](#input\_extra\_ui\_backend\_env\_vars) | Additional environment variables for UI backend container | `map(string)` | `{}` | no |
| <a name="input_extra_ui_static_env_vars"></a> [extra\_ui\_static\_env\_vars](#input\_extra\_ui\_static\_env\_vars) | Additional environment variables for UI static app | `map(string)` | `{}` | no |
| <a name="input_iam_partition"></a> [iam\_partition](#input\_iam\_partition) | IAM Partition (Select aws-us-gov for AWS GovCloud, otherwise leave as is) | `string` | `"aws"` | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | string prefix for all resources | `string` | `"metaflow"` | no |
| <a name="input_resource_suffix"></a> [resource\_suffix](#input\_resource\_suffix) | string suffix for all resources | `string` | `""` | no |
| <a name="input_subnet1_id"></a> [subnet1\_id](#input\_subnet1\_id) | First subnet used for availability zone redundancy | `string` | n/a | yes |
| <a name="input_subnet2_id"></a> [subnet2\_id](#input\_subnet2\_id) | Second subnet used for availability zone redundancy | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | aws tags | `map(string)` | n/a | yes |
| <a name="input_ui_certificate_arn"></a> [ui\_certificate\_arn](#input\_ui\_certificate\_arn) | SSL certificate for UI | `string` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The VPC CIDR block that we'll access list on our Metadata Service API to allow all internal communications | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The id of the single VPC we stood up for all Metaflow resources to exist in. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_METAFLOW_BATCH_JOB_QUEUE"></a> [METAFLOW\_BATCH\_JOB\_QUEUE](#output\_METAFLOW\_BATCH\_JOB\_QUEUE) | AWS Batch Job Queue ARN for Metaflow |
| <a name="output_METAFLOW_DATASTORE_SYSROOT_S3"></a> [METAFLOW\_DATASTORE\_SYSROOT\_S3](#output\_METAFLOW\_DATASTORE\_SYSROOT\_S3) | Amazon S3 URL for Metaflow DataStore |
| <a name="output_METAFLOW_DATATOOLS_S3ROOT"></a> [METAFLOW\_DATATOOLS\_S3ROOT](#output\_METAFLOW\_DATATOOLS\_S3ROOT) | Amazon S3 URL for Metaflow DataTools |
| <a name="output_METAFLOW_ECS_S3_ACCESS_IAM_ROLE"></a> [METAFLOW\_ECS\_S3\_ACCESS\_IAM\_ROLE](#output\_METAFLOW\_ECS\_S3\_ACCESS\_IAM\_ROLE) | Role for AWS Batch to Access Amazon S3 |
| <a name="output_METAFLOW_EVENTS_SFN_ACCESS_IAM_ROLE"></a> [METAFLOW\_EVENTS\_SFN\_ACCESS\_IAM\_ROLE](#output\_METAFLOW\_EVENTS\_SFN\_ACCESS\_IAM\_ROLE) | IAM role for Amazon EventBridge to access AWS Step Functions. |
| <a name="output_METAFLOW_SERVICE_INTERNAL_URL"></a> [METAFLOW\_SERVICE\_INTERNAL\_URL](#output\_METAFLOW\_SERVICE\_INTERNAL\_URL) | URL for Metadata Service (Accessible in VPC) |
| <a name="output_METAFLOW_SERVICE_URL"></a> [METAFLOW\_SERVICE\_URL](#output\_METAFLOW\_SERVICE\_URL) | URL for Metadata Service (Accessible in VPC) |
| <a name="output_METAFLOW_SFN_DYNAMO_DB_TABLE"></a> [METAFLOW\_SFN\_DYNAMO\_DB\_TABLE](#output\_METAFLOW\_SFN\_DYNAMO\_DB\_TABLE) | AWS DynamoDB table name for tracking AWS Step Functions execution metadata. |
| <a name="output_METAFLOW_SFN_IAM_ROLE"></a> [METAFLOW\_SFN\_IAM\_ROLE](#output\_METAFLOW\_SFN\_IAM\_ROLE) | IAM role for AWS Step Functions to access AWS resources (AWS Batch, AWS DynamoDB). |
| <a name="output_api_gateway_rest_api_id_key_id"></a> [api\_gateway\_rest\_api\_id\_key\_id](#output\_api\_gateway\_rest\_api\_id\_key\_id) | API Gateway Key ID for Metadata Service. Fetch Key from AWS Console [METAFLOW\_SERVICE\_AUTH\_KEY] |
| <a name="output_datastore_s3_bucket_kms_key_arn"></a> [datastore\_s3\_bucket\_kms\_key\_arn](#output\_datastore\_s3\_bucket\_kms\_key\_arn) | The ARN of the KMS key used to encrypt the Metaflow datastore S3 bucket |
| <a name="output_metadata_svc_ecs_task_role_arn"></a> [metadata\_svc\_ecs\_task\_role\_arn](#output\_metadata\_svc\_ecs\_task\_role\_arn) | n/a |
| <a name="output_metaflow_api_gateway_rest_api_id"></a> [metaflow\_api\_gateway\_rest\_api\_id](#output\_metaflow\_api\_gateway\_rest\_api\_id) | The ID of the API Gateway REST API we'll use to accept MetaData service requests to forward to the Fargate API instance |
| <a name="output_metaflow_batch_container_image"></a> [metaflow\_batch\_container\_image](#output\_metaflow\_batch\_container\_image) | The ECR repo containing the metaflow batch image |
| <a name="output_metaflow_profile_json"></a> [metaflow\_profile\_json](#output\_metaflow\_profile\_json) | Metaflow profile JSON object that can be used to communicate with this Metaflow Stack. Store this in `~/.metaflow/config_[stack-name]` and select with `$ export METAFLOW_PROFILE=[stack-name]`. |
| <a name="output_metaflow_s3_bucket_arn"></a> [metaflow\_s3\_bucket\_arn](#output\_metaflow\_s3\_bucket\_arn) | The ARN of the bucket we'll be using as blob storage |
| <a name="output_metaflow_s3_bucket_name"></a> [metaflow\_s3\_bucket\_name](#output\_metaflow\_s3\_bucket\_name) | The name of the bucket we'll be using as blob storage |
| <a name="output_migration_function_arn"></a> [migration\_function\_arn](#output\_migration\_function\_arn) | ARN of DB Migration Function |
| <a name="output_ui_alb_dns_name"></a> [ui\_alb\_dns\_name](#output\_ui\_alb\_dns\_name) | UI ALB DNS name |
<!-- END_TF_DOCS -->
