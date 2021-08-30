# Metadata Service

The Metadata Service is a central store for the Metaflow metadata. Namely, it contains information about past runs, and pointers to data artifacts they produced. Metaflow client talks to the Metadata service over an HTTP API endpoint. Metadata service is not strictly required to use Metaflow, especially in the local mode, but it enables a lot of useful functionality, especially if there is more than person using Metaflow in your team.

This terraform module provisions infrastructure to run Metadata service on AWS Fargate.

To read more, see [the Metaflow docs](https://docs.metaflow.org/metaflow-on-aws/metaflow-on-aws#metadata)

### Access control

If the `access_list_cidr_blocks` variable is set, only traffic originating from the specified IP addresses will be accepted. Services internal to AWS can directly access the load balancer used by the API.

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_list_cidr_blocks"></a> [access\_list\_cidr\_blocks](#input\_access\_list\_cidr\_blocks) | List of CIDRs we want to grant access to our Metaflow Metadata Service. Usually this is our VPN's CIDR blocks. | `list(string)` | n/a | yes |
| <a name="input_api_basic_auth"></a> [api\_basic\_auth](#input\_api\_basic\_auth) | Enable basic auth for API Gateway? (requires key export) | `bool` | `true` | no |
| <a name="input_database_password"></a> [database\_password](#input\_database\_password) | The database password | `string` | n/a | yes |
| <a name="input_database_username"></a> [database\_username](#input\_database\_username) | The database username | `string` | n/a | yes |
| <a name="input_datastore_s3_bucket_kms_key_arn"></a> [datastore\_s3\_bucket\_kms\_key\_arn](#input\_datastore\_s3\_bucket\_kms\_key\_arn) | The ARN of the KMS key used to encrypt the Metaflow datastore S3 bucket | `string` | n/a | yes |
| <a name="input_fargate_execution_role_arn"></a> [fargate\_execution\_role\_arn](#input\_fargate\_execution\_role\_arn) | The IAM role that grants access to ECS and Batch services which we'll use as our Metadata Service API's execution\_role for our Fargate instance | `string` | n/a | yes |
| <a name="input_iam_partition"></a> [iam\_partition](#input\_iam\_partition) | IAM Partition (Select aws-us-gov for AWS GovCloud, otherwise leave as is) | `string` | `"aws"` | no |
| <a name="input_is_gov"></a> [is\_gov](#input\_is\_gov) | Set to true if IAM partition is 'aws-us-gov' | `bool` | `false` | no |
| <a name="input_metaflow_vpc_id"></a> [metaflow\_vpc\_id](#input\_metaflow\_vpc\_id) | ID of the Metaflow VPC this SageMaker notebook instance is to be deployed in | `string` | n/a | yes |
| <a name="input_rds_master_instance_endpoint"></a> [rds\_master\_instance\_endpoint](#input\_rds\_master\_instance\_endpoint) | The database connection endpoint in address:port format | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix given to all AWS resources to differentiate between applications | `string` | n/a | yes |
| <a name="input_resource_suffix"></a> [resource\_suffix](#input\_resource\_suffix) | Suffix given to all AWS resources to differentiate between environment and workspace | `string` | n/a | yes |
| <a name="input_s3_bucket_arn"></a> [s3\_bucket\_arn](#input\_s3\_bucket\_arn) | The ARN of the bucket we'll be using as blob storage | `string` | n/a | yes |
| <a name="input_standard_tags"></a> [standard\_tags](#input\_standard\_tags) | The standard tags to apply to every AWS resource. | `map(string)` | n/a | yes |
| <a name="input_subnet1_id"></a> [subnet1\_id](#input\_subnet1\_id) | First private subnet used for availability zone redundancy | `string` | n/a | yes |
| <a name="input_subnet2_id"></a> [subnet2\_id](#input\_subnet2\_id) | Second private subnet used for availability zone redundancy | `string` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The VPC CIDR block that we'll access list on our Metadata Service API to allow all internal communications | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_METAFLOW_SERVICE_INTERNAL_URL"></a> [METAFLOW\_SERVICE\_INTERNAL\_URL](#output\_METAFLOW\_SERVICE\_INTERNAL\_URL) | URL for Metadata Service (Accessible in VPC) |
| <a name="output_METAFLOW_SERVICE_URL"></a> [METAFLOW\_SERVICE\_URL](#output\_METAFLOW\_SERVICE\_URL) | URL for Metadata Service (Open to Public Access) |
| <a name="output_api_gateway_rest_api_id"></a> [api\_gateway\_rest\_api\_id](#output\_api\_gateway\_rest\_api\_id) | The ID of the API Gateway REST API we'll use to accept MetaData service requests to forward to the Fargate API instance |
| <a name="output_api_gateway_rest_api_id_key_id"></a> [api\_gateway\_rest\_api\_id\_key\_id](#output\_api\_gateway\_rest\_api\_id\_key\_id) | API Gateway Key ID for Metadata Service. Fetch Key from AWS Console [METAFLOW\_SERVICE\_AUTH\_KEY] |
| <a name="output_metadata_service_security_group_id"></a> [metadata\_service\_security\_group\_id](#output\_metadata\_service\_security\_group\_id) | The security group ID used by the MetaData service. We'll grant this access to our DB. |
| <a name="output_metadata_svc_ecs_task_role_arn"></a> [metadata\_svc\_ecs\_task\_role\_arn](#output\_metadata\_svc\_ecs\_task\_role\_arn) | This role is passed to AWS ECS' task definition as the `task_role`. This allows the running of the Metaflow Metadata Service to have the proper permissions to speak to other AWS resources. |
| <a name="output_migration_function_arn"></a> [migration\_function\_arn](#output\_migration\_function\_arn) | ARN of DB Migration Function |
| <a name="output_network_load_balancer_dns_name"></a> [network\_load\_balancer\_dns\_name](#output\_network\_load\_balancer\_dns\_name) | The DNS addressable name for the Network Load Balancer that accepts requests and forwards them to our Fargate MetaData service instance(s) |
<!-- END_TF_DOCS -->
