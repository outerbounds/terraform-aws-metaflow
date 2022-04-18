# An example of deploying Metaflow with a EKS cluster

This example will create Metaflow infrastructure from scratch, with a Kubernetes cluster using Amazon EKS. It uses [`datastore`](../../modules/datastore/) and [`metadata-service`](../../modules/metadata-service/) submodules to provision S3 bucket, RDS database and Metaflow Metadata service running on AWS Fargate.

To run Metaflow jobs, it provisions a EKS cluster using [this popular open source terraform module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest). In that cluster, it also installs [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) and [Argo Workflows](https://argoproj.github.io/argo-workflows/) using Helm.

## Instructions

1. Run `terraform apply` to create infrastructure
2. Make note of the EKS cluster name (it is a short string that starts with `mf-`). Use AWS CLI to generate cluster configuration:
    ```bash
    aws eks update-kubeconfig --name <CLUSTER NAME>
    ```
2. Copy `config.json` to `~/.metaflowconfig/`
3. You should be ready to run Metaflow flows using `@kubernetes`
and be able to deploy them to Argo workflows.

Argo Workflows UI is not accessible from outside the cluster, but you can use port forwarding to see it. Run
```bash
kubectl port-forward -n argo service/argo-argo-workflows-server 2746:2746
```
..and you should be able to access it at `localhost:2746`.

## What's missing

⚠️ This is meant as a reference example, with many things omitted for simplicity, such as proper RBAC setup, production-grade autoscaling and UI. We do not recommend using this as a production deployment of Metaflow on Kubernetes.
