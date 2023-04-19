module "argo_events" {
  depends_on     = [helm_release.argo]
  source         = "git::git@github.com:outerbounds/metaflow-tools//common/terraform/argo_events?ref=v2.0.0"
  jobs_namespace = "default"
}
