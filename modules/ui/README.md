# UI

Metaflow operational UI. This module deploys the UI as a set of Fargate tasks. It connects to an existing RDS instance, that can be created by Metaflow [`datastore`](../datastore) module.

The services are deployed behind an AWS ALB, and the module will output the ALB DNS name. This module only comes with rudimentary IP-based auth: only users with IPs matching `ui_allow_list` will be able to access the UI.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_metaflow-common"></a> [metaflow-common](#module\_metaflow-common) | ../common | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.ui_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_service.ui_static](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.ui_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_ecs_task_definition.ui_static](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.metadata_ui_ecs_task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.grant_custom_s3_batch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.grant_deny_presigned_batch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.grant_s3_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_rule.ui_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.ui_backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group.ui_static](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.fargate_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ui_lb_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.custom_s3_batch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.deny_presigned_batch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.metadata_svc_ecs_task_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_METAFLOW_DATASTORE_SYSROOT_S3"></a> [METAFLOW\_DATASTORE\_SYSROOT\_S3](#input\_METAFLOW\_DATASTORE\_SYSROOT\_S3) | METAFLOW\_DATASTORE\_SYSROOT\_S3 value | `string` | n/a | yes |
| <a name="input_alb_internal"></a> [alb\_internal](#input\_alb\_internal) | Defines whether the ALB is internal | `bool` | `false` | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | SSL certificate ARN. The certificate will be used by the UI load balancer. | `string` | n/a | yes |
| <a name="input_cognito_user_pool_arn"></a> [cognito\_user\_pool\_arn](#input\_cognito\_user\_pool\_arn) | The ARN of the Cognito user pool | `string` | `""` | no |
| <a name="input_cognito_user_pool_client_id"></a> [cognito\_user\_pool\_client\_id](#input\_cognito\_user\_pool\_client\_id) | The ID of the Cognito user pool client | `string` | `""` | no |
| <a name="input_cognito_user_pool_domain"></a> [cognito\_user\_pool\_domain](#input\_cognito\_user\_pool\_domain) | The domain of the Cognito user pool | `string` | `""` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | The database name | `string` | `"metaflow"` | no |
| <a name="input_database_password"></a> [database\_password](#input\_database\_password) | The database password | `string` | n/a | yes |
| <a name="input_database_username"></a> [database\_username](#input\_database\_username) | The database username | `string` | n/a | yes |
| <a name="input_datastore_s3_bucket_kms_key_arn"></a> [datastore\_s3\_bucket\_kms\_key\_arn](#input\_datastore\_s3\_bucket\_kms\_key\_arn) | The ARN of the KMS key used to encrypt the Metaflow datastore S3 bucket | `string` | n/a | yes |
| <a name="input_ecs_cluster_settings"></a> [ecs\_cluster\_settings](#input\_ecs\_cluster\_settings) | Settings for the ECS cluster | `map(string)` | `{}` | no |
| <a name="input_extra_ui_backend_env_vars"></a> [extra\_ui\_backend\_env\_vars](#input\_extra\_ui\_backend\_env\_vars) | Additional environment variables for UI backend container | `map(string)` | `{}` | no |
| <a name="input_extra_ui_static_env_vars"></a> [extra\_ui\_static\_env\_vars](#input\_extra\_ui\_static\_env\_vars) | Additional environment variables for UI static app | `map(string)` | `{}` | no |
| <a name="input_fargate_execution_role_arn"></a> [fargate\_execution\_role\_arn](#input\_fargate\_execution\_role\_arn) | This role allows Fargate to pull container images and logs. We'll use it as execution\_role for our Fargate task | `string` | n/a | yes |
| <a name="input_iam_partition"></a> [iam\_partition](#input\_iam\_partition) | IAM Partition (Select aws-us-gov for AWS GovCloud, otherwise leave as is) | `string` | `"aws"` | no |
| <a name="input_is_gov"></a> [is\_gov](#input\_is\_gov) | Set to true if IAM partition is 'aws-us-gov' | `bool` | `false` | no |
| <a name="input_load_balancer_name_prefix"></a> [load\_balancer\_name\_prefix](#input\_load\_balancer\_name\_prefix) | Prefix for all load balancer names | `string` | `""` | no |
| <a name="input_metadata_service_security_group_id"></a> [metadata\_service\_security\_group\_id](#input\_metadata\_service\_security\_group\_id) | The security group ID used by the MetaData service. This security group should allow connections to the RDS instance. | `string` | n/a | yes |
| <a name="input_metaflow_vpc_id"></a> [metaflow\_vpc\_id](#input\_metaflow\_vpc\_id) | VPC to deploy services into | `string` | n/a | yes |
| <a name="input_rds_master_instance_endpoint"></a> [rds\_master\_instance\_endpoint](#input\_rds\_master\_instance\_endpoint) | The database connection endpoint in address:port format | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix given to all AWS resources to differentiate between applications | `string` | n/a | yes |
| <a name="input_resource_suffix"></a> [resource\_suffix](#input\_resource\_suffix) | Suffix given to all AWS resources to differentiate between environment and workspace | `string` | n/a | yes |
| <a name="input_s3_bucket_arn"></a> [s3\_bucket\_arn](#input\_s3\_bucket\_arn) | The ARN of the bucket used for Metaflow datastore | `string` | n/a | yes |
| <a name="input_standard_tags"></a> [standard\_tags](#input\_standard\_tags) | The standard tags to apply to every AWS resource. | `map(string)` | n/a | yes |
| <a name="input_subnet1_id"></a> [subnet1\_id](#input\_subnet1\_id) | First private subnet used for availability zone redundancy | `string` | n/a | yes |
| <a name="input_subnet2_id"></a> [subnet2\_id](#input\_subnet2\_id) | Second private subnet used for availability zone redundancy | `string` | n/a | yes |
| <a name="input_ui_allow_list"></a> [ui\_allow\_list](#input\_ui\_allow\_list) | A list of CIDRs the UI will be available to | `list(string)` | `[]` | no |
| <a name="input_ui_backend_container_image"></a> [ui\_backend\_container\_image](#input\_ui\_backend\_container\_image) | Container image for UI backend | `string` | `""` | no |
| <a name="input_ui_static_container_image"></a> [ui\_static\_container\_image](#input\_ui\_static\_container\_image) | Container image for the UI frontend app | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_arn"></a> [alb\_arn](#output\_alb\_arn) | UI ALB ARN |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | UI ALB DNS name |
<!-- END_TF_DOCS -->
