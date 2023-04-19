module "argo_events" {
  depends_on     = [helm_release.argo]
  source         = "./argo_events"
  jobs_namespace = "default"
}
