locals {
  deploy_argo = true
  deploy_airflow = false

  # Airflow Related Options
  airflow_version = "2.3.3"
  airflow_frenet_secret = "myverysecretvalue"
  airflow_dags_sync_prefix = "airflow-dags"
  airflow_dag_sync_frequency = "30"
  airflow_executor = "KubernetesExecutor" # Can be changed to LocalExecutor
}

