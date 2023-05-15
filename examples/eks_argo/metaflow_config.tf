data "aws_api_gateway_api_key" "metadata_api_key" {
  id = module.metaflow-metadata-service.api_gateway_rest_api_id_key_id
}

resource "local_file" "foo" {
  content = jsonencode({
    "METAFLOW_SERVICE_AUTH_KEY"            = data.aws_api_gateway_api_key.metadata_api_key.value
    "METAFLOW_DATASTORE_SYSROOT_S3"        = module.metaflow-datastore.METAFLOW_DATASTORE_SYSROOT_S3
    "METAFLOW_DATATOOLS_S3ROOT"            = module.metaflow-datastore.METAFLOW_DATATOOLS_S3ROOT
    "METAFLOW_SERVICE_URL"                 = module.metaflow-metadata-service.METAFLOW_SERVICE_URL
    "METAFLOW_KUBERNETES_NAMESPACE"        = "default"
    "METAFLOW_KUBERNETES_SERVICE_ACCOUNT"  = "argo-workflow"
    "METAFLOW_DEFAULT_DATASTORE"           = "s3"
    "METAFLOW_DEFAULT_METADATA"            = "service"
    "METAFLOW_ARGO_EVENTS_EVENT_BUS"       = "default"
    "METAFLOW_ARGO_EVENTS_EVENT_SOURCE"    = "argo-events-webhook"
    "METAFLOW_ARGO_EVENTS_SERVICE_ACCOUNT" = "operate-workflow-sa"
    "METAFLOW_ARGO_EVENTS_EVENT"           = "metaflow-event"
    "METAFLOW_ARGO_EVENTS_WEBHOOK_URL"     = "http://argo-events-webhook-eventsource-svc.default:12000/metaflow-event"
  })
  filename = "${path.module}/config.json"
}
