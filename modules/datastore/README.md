# Datastore

Stores Metaflow state, acting as Metaflow's remote Datastore. The data stored includes but is not limited:

- for each flow
  - for each version
    - conda environments
    - dependencies
    - artifacts
    - input
    - output

No duplicate data is stored thanks to automatic deduplication built into Metaflow.

To read more, see [the Metaflow docs](https://docs.metaflow.org/metaflow-on-aws/metaflow-on-aws#datastore)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.38.0, != 4.8.0, != 4.7.0, != 4.6.0, != 4.5.0, != 4.4.0, != 4.3.0, != 4.2.0, != 4.1.0, != 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.38.0, != 4.8.0, != 4.7.0, != 4.6.0, != 4.5.0, != 4.4.0, != 4.3.0, != 4.2.0, != 4.1.0, != 4.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_parameter_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |
| [aws_db_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_kms_key.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_rds_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster) | resource |
| [aws_rds_cluster_instance.cluster_instances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_security_group.rds_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_pet.final_snapshot_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Apply RDS modifications immediately, or wait for Maintenance Window | `bool` | `false` | no |
| <a name="input_bucket_key_enabled"></a> [bucket\_key\_enabled](#input\_bucket\_key\_enabled) | Whether or not to use Amazon S3 Bucket Keys for SSE-KMS | `bool` | `false` | no |
| <a name="input_ca_cert_identifier"></a> [ca\_cert\_identifier](#input\_ca\_cert\_identifier) | RDS CA cert identifier for the DB Instances, or leave blank for RDS default | `string` | `""` | no |
| <a name="input_db_engine"></a> [db\_engine](#input\_db\_engine) | n/a | `string` | `"postgres"` | no |
| <a name="input_db_engine_version"></a> [db\_engine\_version](#input\_db\_engine\_version) | n/a | `string` | `"11"` | no |
| <a name="input_db_identifier_prefix"></a> [db\_identifier\_prefix](#input\_db\_identifier\_prefix) | Identifier prefix for the RDS instance | `string` | `""` | no |
| <a name="input_db_instance_tags"></a> [db\_instance\_tags](#input\_db\_instance\_tags) | A map of additional tags for the DB instance | `map(string)` | `{}` | no |
| <a name="input_db_instance_type"></a> [db\_instance\_type](#input\_db\_instance\_type) | RDS instance type to launch for PostgresQL database. | `string` | `"db.t2.small"` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Name of PostgresQL database for Metaflow service. | `string` | `"metaflow"` | no |
| <a name="input_db_parameters"></a> [db\_parameters](#input\_db\_parameters) | A map of parameters to apply to the DB instance | `map(string)` | `{}` | no |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | PostgresQL username; defaults to 'metaflow' | `string` | `"metaflow"` | no |
| <a name="input_force_destroy_s3_bucket"></a> [force\_destroy\_s3\_bucket](#input\_force\_destroy\_s3\_bucket) | Empty S3 bucket before destroying via terraform destroy | `bool` | `false` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Maintenance Window in format "ddd:hh24:mi-ddd:hh24:mi" eg. "Mon:00:00-Mon:03:00", or leave blank to randomise | `string` | `""` | no |
| <a name="input_metadata_service_security_group_id"></a> [metadata\_service\_security\_group\_id](#input\_metadata\_service\_security\_group\_id) | The security group ID used by the MetaData service. We'll grant this access to our DB. | `string` | n/a | yes |
| <a name="input_metaflow_vpc_id"></a> [metaflow\_vpc\_id](#input\_metaflow\_vpc\_id) | ID of the Metaflow VPC this SageMaker notebook instance is to be deployed in | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix given to all AWS resources to differentiate between applications | `string` | n/a | yes |
| <a name="input_resource_suffix"></a> [resource\_suffix](#input\_resource\_suffix) | Suffix given to all AWS resources to differentiate between environment and workspace | `string` | n/a | yes |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | The name of the S3 bucket used for Metaflow datastore | `string` | `""` | no |
| <a name="input_standard_tags"></a> [standard\_tags](#input\_standard\_tags) | The standard tags to apply to every AWS resource. | `map(string)` | n/a | yes |
| <a name="input_subnet1_id"></a> [subnet1\_id](#input\_subnet1\_id) | First subnet used for availability zone redundancy | `string` | n/a | yes |
| <a name="input_subnet2_id"></a> [subnet2\_id](#input\_subnet2\_id) | Second subnet used for availability zone redundancy | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_METAFLOW_DATASTORE_SYSROOT_S3"></a> [METAFLOW\_DATASTORE\_SYSROOT\_S3](#output\_METAFLOW\_DATASTORE\_SYSROOT\_S3) | Amazon S3 URL for Metaflow DataStore |
| <a name="output_METAFLOW_DATATOOLS_S3ROOT"></a> [METAFLOW\_DATATOOLS\_S3ROOT](#output\_METAFLOW\_DATATOOLS\_S3ROOT) | Amazon S3 URL for Metaflow DataTools |
| <a name="output_database_name"></a> [database\_name](#output\_database\_name) | The database name |
| <a name="output_database_password"></a> [database\_password](#output\_database\_password) | The database password |
| <a name="output_database_username"></a> [database\_username](#output\_database\_username) | The database username |
| <a name="output_datastore_s3_bucket_kms_key_arn"></a> [datastore\_s3\_bucket\_kms\_key\_arn](#output\_datastore\_s3\_bucket\_kms\_key\_arn) | The ARN of the KMS key used to encrypt the Metaflow datastore S3 bucket |
| <a name="output_rds_master_instance_endpoint"></a> [rds\_master\_instance\_endpoint](#output\_rds\_master\_instance\_endpoint) | The database connection endpoint in address:port format |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | The ARN of the bucket we'll be using as blob storage |
| <a name="output_s3_bucket_name"></a> [s3\_bucket\_name](#output\_s3\_bucket\_name) | The name of the bucket we'll be using as blob storage |
<!-- END_TF_DOCS -->
