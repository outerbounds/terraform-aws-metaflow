# UI

Metaflow operational UI. This module deploys the UI as a set of Fargate tasks. It connects to an existing RDS instance, that can be created by Metaflow [`datastore`](../datastore) module.

The services are deployed behind an AWS ALB, and the module will output the ALB DNS name. This module only comes with rudimentary IP-based auth: only users with IPs matching `ui_allow_list` will be able to access the UI.

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_METAFLOW_DATASTORE_SYSROOT_S3"></a> [METAFLOW\_DATASTORE\_SYSROOT\_S3](#input\_METAFLOW\_DATASTORE\_SYSROOT\_S3) | METAFLOW\_DATASTORE\_SYSROOT\_S3 value | `string` | n/a | yes |
| <a name="input_alb_internal"></a> [alb\_internal](#input\_alb\_internal) | Defines whether the ALB is internal | `bool` | `false` | no |
| <a name="input_alb_subnet_ids"></a> [alb\_subnet\_ids](#input\_alb\_subnet\_ids) | A list of private or public subnet ids to be used for hosting the UI ALB. This is configured separately from other instances to allow users to specify a public subnet for the ALB while using private subnets for the rest of the components | `list(string)` | n/a | yes |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | SSL certificate ARN. The certificate will be used by the UI load balancer. | `string` | n/a | yes |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | The database name | `string` | `"metaflow"` | no |
| <a name="input_database_password"></a> [database\_password](#input\_database\_password) | The database password | `string` | n/a | yes |
| <a name="input_database_username"></a> [database\_username](#input\_database\_username) | The database username | `string` | n/a | yes |
| <a name="input_datastore_s3_bucket_kms_key_arn"></a> [datastore\_s3\_bucket\_kms\_key\_arn](#input\_datastore\_s3\_bucket\_kms\_key\_arn) | The ARN of the KMS key used to encrypt the Metaflow datastore S3 bucket | `string` | n/a | yes |
| <a name="input_extra_ui_backend_env_vars"></a> [extra\_ui\_backend\_env\_vars](#input\_extra\_ui\_backend\_env\_vars) | Additional environment variables for UI backend container | `map(string)` | `{}` | no |
| <a name="input_extra_ui_static_env_vars"></a> [extra\_ui\_static\_env\_vars](#input\_extra\_ui\_static\_env\_vars) | Additional environment variables for UI static app | `map(string)` | `{}` | no |
| <a name="input_fargate_execution_role_arn"></a> [fargate\_execution\_role\_arn](#input\_fargate\_execution\_role\_arn) | This role allows Fargate to pull container images and logs. We'll use it as execution\_role for our Fargate task | `string` | n/a | yes |
| <a name="input_iam_partition"></a> [iam\_partition](#input\_iam\_partition) | IAM Partition (Select aws-us-gov for AWS GovCloud, otherwise leave as is) | `string` | `"aws"` | no |
| <a name="input_is_gov"></a> [is\_gov](#input\_is\_gov) | Set to true if IAM partition is 'aws-us-gov' | `bool` | `false` | no |
| <a name="input_metadata_service_security_group_id"></a> [metadata\_service\_security\_group\_id](#input\_metadata\_service\_security\_group\_id) | The security group ID used by the MetaData service. This security group should allow connections to the RDS instance. | `string` | n/a | yes |
| <a name="input_metaflow_vpc_id"></a> [metaflow\_vpc\_id](#input\_metaflow\_vpc\_id) | VPC to deploy services into | `string` | n/a | yes |
| <a name="input_rds_master_instance_endpoint"></a> [rds\_master\_instance\_endpoint](#input\_rds\_master\_instance\_endpoint) | The database connection endpoint in address:port format | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix given to all AWS resources to differentiate between applications | `string` | n/a | yes |
| <a name="input_resource_suffix"></a> [resource\_suffix](#input\_resource\_suffix) | Suffix given to all AWS resources to differentiate between environment and workspace | `string` | n/a | yes |
| <a name="input_s3_bucket_arn"></a> [s3\_bucket\_arn](#input\_s3\_bucket\_arn) | The ARN of the bucket used for Metaflow datastore | `string` | n/a | yes |
| <a name="input_standard_tags"></a> [standard\_tags](#input\_standard\_tags) | The standard tags to apply to every AWS resource. | `map(string)` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of private or public subnet ids used for creating Metaflow UI deployment | `list(string)` | n/a | yes |
| <a name="input_ui_allow_list"></a> [ui\_allow\_list](#input\_ui\_allow\_list) | A list of CIDRs the UI will be available to | `list(string)` | `[]` | no |
| <a name="input_ui_backend_container_image"></a> [ui\_backend\_container\_image](#input\_ui\_backend\_container\_image) | Container image for UI backend | `string` | `""` | no |
| <a name="input_ui_static_container_image"></a> [ui\_static\_container\_image](#input\_ui\_static\_container\_image) | Container image for the UI frontend app | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | UI ALB ARN |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | UI ALB DNS name |
<!-- END_TF_DOCS -->
