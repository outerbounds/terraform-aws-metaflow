[![](https://img.shields.io/badge/slack-@outerbounds-purple.svg?logo=slack )](http://slack.outerbounds.co/)

# Metaflow Terraform module

Terraform module that provisions AWS resources to run [Metaflow](https://metaflow.org/) in production.

This module consists of submodules that can be used separately as well:

- AWS Batch cluster to run Metaflow steps ([`metaflow-computation`](./modules/computation))
- blob storage and metadata database ([`metaflow-datastore`](./modules/datastore))
- a service providing API to record and query past executions ([`metaflow-metadata-service`](./modules/metadata-service))
- resources to deploy Metaflow flows on Step Functions processing ([`metaflow-step-functions`](./modules/step-functions))
- Metaflow UI([`metaflow-ui`](./modules/ui))

![modules diagram](./docs/terraform_modules.png)

You can either use this high-level module, or submodules individually. See each module's corresponding `README.md` for more details.

Here's a minimal end-to-end example of using this module with VPC:
```terraform
# Random suffix for this deployment
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper = false
}

locals {
  resource_prefix = "metaflow"
  resource_suffix = random_string.suffix.result
}

data "aws_availability_zones" "available" {
}

# VPC infra using https://github.com/terraform-aws-modules/terraform-aws-vpc
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.13.0"

  name = "${local.resource_prefix}-${local.resource_suffix}"
  cidr = "10.10.0.0/16"

  azs             = data.aws_availability_zones.available.names
  private_subnets = ["10.10.8.0/21", "10.10.16.0/21", "10.10.24.0/21"]
  public_subnets  = ["10.10.128.0/21", "10.10.136.0/21", "10.10.144.0/21"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}


module "metaflow" {
  source = "outerbounds/metaflow/aws"
  version = "0.3.0"

  resource_prefix = local.resource_prefix
  resource_suffix = local.resource_suffix

  enable_step_functions = false
  subnet1_id            = module.vpc.public_subnets[0]
  subnet2_id            = module.vpc.public_subnets[1]
  vpc_cidr_blocks       = module.vpc.vpc_cidr_blocks
  vpc_id                = module.vpc.vpc_id
  with_public_ip        = var.with_public_ip

  tags = {
      "managedBy" = "terraform"
  }
}

# The module will generate a Metaflow config in JSON format, write it to a file
resource "local_file" "metaflow_config" {
  content  = module.metaflow.metaflow_profile_json
  filename = "./metaflow_profile.json"
}
```

You can find a more complete example that uses this module but also includes setting up sagemaker notebooks and other non-Metaflow-specific parts of infra [in this repo](https://github.com/outerbounds/metaflow-tools/tree/master/aws/terraform).

<!-- BEGIN_TF_DOCS -->
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_metaflow-common"></a> [metaflow-common](#module\_metaflow-common) | ./modules/common | n/a |
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
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Apply RDS modifications immediately, or wait for Maintenance Window | `bool` | `false` | no |
| <a name="input_batch_cluster_name"></a> [batch\_cluster\_name](#input\_batch\_cluster\_name) | The name of the ECS cluster to use for batch processing | `string` | `""` | no |
| <a name="input_batch_type"></a> [batch\_type](#input\_batch\_type) | AWS Batch Compute Type ('ec2', 'fargate') | `string` | `"ec2"` | no |
| <a name="input_bucket_key_enabled"></a> [bucket\_key\_enabled](#input\_bucket\_key\_enabled) | Whether or not to use Amazon S3 Bucket Keys for SSE-KMS | `bool` | `false` | no |
| <a name="input_ca_cert_identifier"></a> [ca\_cert\_identifier](#input\_ca\_cert\_identifier) | RDS CA cert identifier for the DB Instances, or leave blank for RDS default | `string` | `""` | no |
| <a name="input_compute_environment_desired_vcpus"></a> [compute\_environment\_desired\_vcpus](#input\_compute\_environment\_desired\_vcpus) | Desired Starting VCPUs for Batch Compute Environment [0-16] for EC2 Batch Compute Environment (ignored for Fargate) | `number` | `8` | no |
| <a name="input_compute_environment_egress_cidr_blocks"></a> [compute\_environment\_egress\_cidr\_blocks](#input\_compute\_environment\_egress\_cidr\_blocks) | CIDR blocks to which egress is allowed from the Batch Compute environment's security group | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_compute_environment_instance_types"></a> [compute\_environment\_instance\_types](#input\_compute\_environment\_instance\_types) | The instance types for the compute environment | `list(string)` | <pre>[<br/>  "c4.large",<br/>  "c4.xlarge",<br/>  "c4.2xlarge",<br/>  "c4.4xlarge",<br/>  "c4.8xlarge"<br/>]</pre> | no |
| <a name="input_compute_environment_max_vcpus"></a> [compute\_environment\_max\_vcpus](#input\_compute\_environment\_max\_vcpus) | Maximum VCPUs for Batch Compute Environment [16-96] | `number` | `64` | no |
| <a name="input_compute_environment_min_vcpus"></a> [compute\_environment\_min\_vcpus](#input\_compute\_environment\_min\_vcpus) | Minimum VCPUs for Batch Compute Environment [0-16] for EC2 Batch Compute Environment (ignored for Fargate) | `number` | `8` | no |
| <a name="input_db_engine_version"></a> [db\_engine\_version](#input\_db\_engine\_version) | n/a | `string` | `"11"` | no |
| <a name="input_db_identifier_prefix"></a> [db\_identifier\_prefix](#input\_db\_identifier\_prefix) | Identifier prefix for the RDS instance | `string` | `""` | no |
| <a name="input_db_instance_tags"></a> [db\_instance\_tags](#input\_db\_instance\_tags) | A map of additional tags for the DB instance | `map(string)` | `{}` | no |
| <a name="input_db_instance_type"></a> [db\_instance\_type](#input\_db\_instance\_type) | RDS instance type to launch for PostgresQL database. | `string` | `"db.t2.small"` | no |
| <a name="input_db_migrate_lambda_runtime"></a> [db\_migrate\_lambda\_runtime](#input\_db\_migrate\_lambda\_runtime) | Runtime version for the DB migrate lambda | `string` | `"python3.7"` | no |
| <a name="input_db_migrate_lambda_zip_file"></a> [db\_migrate\_lambda\_zip\_file](#input\_db\_migrate\_lambda\_zip\_file) | Output path for the zip file containing the DB migrate lambda | `string` | `null` | no |
| <a name="input_db_parameters"></a> [db\_parameters](#input\_db\_parameters) | A map of parameters to apply to the DB instance | `map(string)` | `{}` | no |
| <a name="input_ecs_cluster_settings"></a> [ecs\_cluster\_settings](#input\_ecs\_cluster\_settings) | Settings for the ECS cluster | `map(string)` | `{}` | no |
| <a name="input_enable_custom_batch_container_registry"></a> [enable\_custom\_batch\_container\_registry](#input\_enable\_custom\_batch\_container\_registry) | Provisions infrastructure for custom Amazon ECR container registry if enabled | `bool` | `false` | no |
| <a name="input_enable_step_functions"></a> [enable\_step\_functions](#input\_enable\_step\_functions) | Provisions infrastructure for step functions if enabled | `bool` | n/a | yes |
| <a name="input_extra_ui_backend_env_vars"></a> [extra\_ui\_backend\_env\_vars](#input\_extra\_ui\_backend\_env\_vars) | Additional environment variables for UI backend container | `map(string)` | `{}` | no |
| <a name="input_extra_ui_static_env_vars"></a> [extra\_ui\_static\_env\_vars](#input\_extra\_ui\_static\_env\_vars) | Additional environment variables for UI static app | `map(string)` | `{}` | no |
| <a name="input_iam_partition"></a> [iam\_partition](#input\_iam\_partition) | IAM Partition (Select aws-us-gov for AWS GovCloud, otherwise leave as is) | `string` | `"aws"` | no |
| <a name="input_launch_template_http_endpoint"></a> [launch\_template\_http\_endpoint](#input\_launch\_template\_http\_endpoint) | Whether the metadata service is available. Can be 'enabled' or 'disabled' | `string` | `"enabled"` | no |
| <a name="input_launch_template_http_put_response_hop_limit"></a> [launch\_template\_http\_put\_response\_hop\_limit](#input\_launch\_template\_http\_put\_response\_hop\_limit) | The desired HTTP PUT response hop limit for instance metadata requests. Can be an integer from 1 to 64 | `number` | `2` | no |
| <a name="input_launch_template_http_tokens"></a> [launch\_template\_http\_tokens](#input\_launch\_template\_http\_tokens) | Whether or not the metadata service requires session tokens, also referred to as Instance Metadata Service Version 2 (IMDSv2). Can be 'optional' or 'required' | `string` | `"optional"` | no |
| <a name="input_load_balancer_name_prefix"></a> [load\_balancer\_name\_prefix](#input\_load\_balancer\_name\_prefix) | Prefix for all load balancer names | `string` | `""` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Maintenance Window in format "ddd:hh24:mi-ddd:hh24:mi" eg. "Mon:00:00-Mon:03:00", or leave blank to randomise | `string` | `""` | no |
| <a name="input_metadata_service_container_image"></a> [metadata\_service\_container\_image](#input\_metadata\_service\_container\_image) | Container image for metadata service | `string` | `""` | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | string prefix for all resources | `string` | `"metaflow"` | no |
| <a name="input_resource_suffix"></a> [resource\_suffix](#input\_resource\_suffix) | string suffix for all resources | `string` | `""` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | The name of the S3 bucket used for Metaflow datastore | `string` | `""` | no |
| <a name="input_subnet1_id"></a> [subnet1\_id](#input\_subnet1\_id) | First subnet used for availability zone redundancy | `string` | n/a | yes |
| <a name="input_subnet2_id"></a> [subnet2\_id](#input\_subnet2\_id) | Second subnet used for availability zone redundancy | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | aws tags | `map(string)` | n/a | yes |
| <a name="input_ui_alb_internal"></a> [ui\_alb\_internal](#input\_ui\_alb\_internal) | Defines whether the ALB for the UI is internal | `bool` | `false` | no |
| <a name="input_ui_allow_list"></a> [ui\_allow\_list](#input\_ui\_allow\_list) | List of CIDRs we want to grant access to our Metaflow UI Service. Usually this is our VPN's CIDR blocks. | `list(string)` | `[]` | no |
| <a name="input_ui_certificate_arn"></a> [ui\_certificate\_arn](#input\_ui\_certificate\_arn) | SSL certificate for UI. | `string` | n/a | yes |
| <a name="input_ui_cognito_user_pool_arn"></a> [ui\_cognito\_user\_pool\_arn](#input\_ui\_cognito\_user\_pool\_arn) | The ARN of the Cognito user pool | `string` | `""` | no |
| <a name="input_ui_cognito_user_pool_client_id"></a> [ui\_cognito\_user\_pool\_client\_id](#input\_ui\_cognito\_user\_pool\_client\_id) | The ID of the Cognito user pool client | `string` | `""` | no |
| <a name="input_ui_cognito_user_pool_domain"></a> [ui\_cognito\_user\_pool\_domain](#input\_ui\_cognito\_user\_pool\_domain) | The domain of the Cognito user pool | `string` | `""` | no |
| <a name="input_ui_static_container_image"></a> [ui\_static\_container\_image](#input\_ui\_static\_container\_image) | Container image for the UI frontend app | `string` | `""` | no |
| <a name="input_vpc_cidr_blocks"></a> [vpc\_cidr\_blocks](#input\_vpc\_cidr\_blocks) | The VPC CIDR blocks that we'll access list on our Metadata Service API to allow all internal communications | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The id of the single VPC we stood up for all Metaflow resources to exist in. | `string` | n/a | yes |
| <a name="input_with_public_ip"></a> [with\_public\_ip](#input\_with\_public\_ip) | Enable public IP assignment for the Metadata Service. Typically you want this to be set to true if using public subnets as subnet1\_id and subnet2\_id, and false otherwise | `bool` | `false` | no |

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
| <a name="output_batch_compute_environment_security_group_id"></a> [batch\_compute\_environment\_security\_group\_id](#output\_batch\_compute\_environment\_security\_group\_id) | The ID of the security group attached to the Batch Compute environment. |
| <a name="output_datastore_s3_bucket_kms_key_arn"></a> [datastore\_s3\_bucket\_kms\_key\_arn](#output\_datastore\_s3\_bucket\_kms\_key\_arn) | The ARN of the KMS key used to encrypt the Metaflow datastore S3 bucket |
| <a name="output_metadata_svc_ecs_task_role_arn"></a> [metadata\_svc\_ecs\_task\_role\_arn](#output\_metadata\_svc\_ecs\_task\_role\_arn) | n/a |
| <a name="output_metaflow_api_gateway_rest_api_id"></a> [metaflow\_api\_gateway\_rest\_api\_id](#output\_metaflow\_api\_gateway\_rest\_api\_id) | The ID of the API Gateway REST API we'll use to accept MetaData service requests to forward to the Fargate API instance |
| <a name="output_metaflow_batch_container_image"></a> [metaflow\_batch\_container\_image](#output\_metaflow\_batch\_container\_image) | The ECR repo containing the metaflow batch image |
| <a name="output_metaflow_profile_json"></a> [metaflow\_profile\_json](#output\_metaflow\_profile\_json) | Metaflow profile JSON object that can be used to communicate with this Metaflow Stack. Store this in `~/.metaflow/config_[stack-name]` and select with `$ export METAFLOW_PROFILE=[stack-name]`. |
| <a name="output_metaflow_s3_bucket_arn"></a> [metaflow\_s3\_bucket\_arn](#output\_metaflow\_s3\_bucket\_arn) | The ARN of the bucket we'll be using as blob storage |
| <a name="output_metaflow_s3_bucket_name"></a> [metaflow\_s3\_bucket\_name](#output\_metaflow\_s3\_bucket\_name) | The name of the bucket we'll be using as blob storage |
| <a name="output_migration_function_arn"></a> [migration\_function\_arn](#output\_migration\_function\_arn) | ARN of DB Migration Function |
| <a name="output_ui_alb_arn"></a> [ui\_alb\_arn](#output\_ui\_alb\_arn) | UI ALB ARN |
| <a name="output_ui_alb_dns_name"></a> [ui\_alb\_dns\_name](#output\_ui\_alb\_dns\_name) | UI ALB DNS name |
<!-- END_TF_DOCS -->
