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
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_security_group_ids"></a> [allowed\_security\_group\_ids](#input\_allowed\_security\_group\_ids) | A list of security group ids that have access to the RDS instance | `list(string)` | `[]` | no |
| <a name="input_db_engine"></a> [db\_engine](#input\_db\_engine) | n/a | `string` | `"postgres"` | no |
| <a name="input_db_engine_version"></a> [db\_engine\_version](#input\_db\_engine\_version) | n/a | `string` | `"11"` | no |
| <a name="input_db_instance_type"></a> [db\_instance\_type](#input\_db\_instance\_type) | RDS instance type to launch for PostgresQL database. | `string` | `"db.t3.small"` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Name of PostgresQL database for Metaflow service. | `string` | `"metaflow"` | no |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | PostgresQL username; defaults to 'metaflow' | `string` | `"metaflow"` | no |
| <a name="input_enable_key_rotation"></a> [enable\_key\_rotation](#input\_enable\_key\_rotation) | Enable key rotation for KMS keys | `bool` | `false` | no |
| <a name="input_force_destroy_s3_bucket"></a> [force\_destroy\_s3\_bucket](#input\_force\_destroy\_s3\_bucket) | Empty S3 bucket before destroying via terraform destroy | `bool` | `false` | no |
| <a name="input_metadata_service_security_group_id"></a> [metadata\_service\_security\_group\_id](#input\_metadata\_service\_security\_group\_id) | DEPRECATED: The security group ID used by the MetaData service. We'll grant this access to our DB. | `string` | `""` | no |
| <a name="input_metaflow_vpc_id"></a> [metaflow\_vpc\_id](#input\_metaflow\_vpc\_id) | ID of the Metaflow VPC this SageMaker notebook instance is to be deployed in | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix given to all AWS resources to differentiate between applications | `string` | n/a | yes |
| <a name="input_resource_suffix"></a> [resource\_suffix](#input\_resource\_suffix) | Suffix given to all AWS resources to differentiate between environment and workspace | `string` | n/a | yes |
| <a name="input_standard_tags"></a> [standard\_tags](#input\_standard\_tags) | The standard tags to apply to every AWS resource. | `map(string)` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnets to use for creating database instances | `list(string)` | n/a | yes |
| <a name="input_vpc_cidr_blocks"></a> [vpc\_cidr\_blocks](#input\_vpc\_cidr\_blocks) | Current CIDR block for the VPC | `list(string)` | n/a | yes |

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
