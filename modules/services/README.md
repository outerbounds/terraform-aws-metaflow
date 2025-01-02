<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deploy_metaflow_service"></a> [deploy\_metaflow\_service](#input\_deploy\_metaflow\_service) | Deploy the Metaflow service | `bool` | `true` | no |
| <a name="input_google_access_token"></a> [google\_access\_token](#input\_google\_access\_token) | The google access token | `string` | `""` | no |
| <a name="input_kubernetes_cluster_ca_certificate"></a> [kubernetes\_cluster\_ca\_certificate](#input\_kubernetes\_cluster\_ca\_certificate) | The Kubernetes cluster CA certificate | `string` | `""` | no |
| <a name="input_kubernetes_cluster_host"></a> [kubernetes\_cluster\_host](#input\_kubernetes\_cluster\_host) | The Kubernetes cluster host | `string` | `""` | no |
| <a name="input_metaflow_database"></a> [metaflow\_database](#input\_metaflow\_database) | Properties of the database that will be used to store metadata about Metaflow runs | <pre>object({<br/>    database_name = string<br/>    host          = string<br/>    user          = string<br/>    password      = string<br/>  })</pre> | `null` | no |
| <a name="input_resource_name_prefix"></a> [resource\_name\_prefix](#input\_resource\_name\_prefix) | The prefix to use for all resources | `string` | `""` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
