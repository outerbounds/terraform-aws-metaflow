# An example of deploying Metaflow with Argo on an EKS cluster

This example will create Metaflow infrastructure from scratch, with a Kubernetes cluster using Amazon EKS. It uses [`datastore`](../../modules/datastore/) and [`metadata-service`](../../modules/metadata-service/) submodules to provision S3 bucket, RDS database and Metaflow Metadata service running on AWS Fargate.

To run Metaflow jobs, it provisions a EKS cluster using [this popular open source terraform module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest). In that cluster, it also installs [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) and [Argo Workflows](https://argoproj.github.io/argo-workflows/) using Helm.

Specifically, it'll create following resources in your AWS account:
* General networking infra:
    * AWS VPC
    * NAT gateway for private subnets in the VPC
* For storing data artifacts:
    * S3 bucket
* For Metaflow metadata:
    * RDS Database instance (on-demand, Multi-AZ, db.t2.small)
    * ECS service for Metaflow Metadata service
    * Network load balancer
    * API Gateway
* For executing Metaflow tasks:
    * Autoscaling EKS cluster with at least one instance running

Note that all this infrastructure costs a non-trivial amount at rest, up to $400/month and more if being actively used.

## Instructions

0. Run `terraform init`
1. Run `terraform apply` to create infrastructure. This command will typically take ~20 minutes to execute.
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

## Destroying the infrastructure

Note that this will destroy everything including the S3 bucket with artifacts!

Run `terraform destroy`

# What's missing

⚠️ This is meant as a reference example, with many things omitted for simplicity, such as proper RBAC setup, production-grade autoscaling and UI. For example, all workloads running in the cluster use the same AWS IAM role. We do not recommend using this as a production deployment of Metaflow on Kubernetes.

For learn more about production-grade deployments, you can talk to us on [the Outerbounds slack](http://slack.outerbounds.co). We are happy to help you there!

# Advanced topics

Q: How to publish an Argo Event from outside the Kubernetes cluster?
A:
Establish port forward for Argo Events Webhook server:

$ kubectl port-forward -n default service/argo-events-webhook-eventsource-svc 12000:12000

Here is a snippet that publishes the event "foo" (consume this event with `@trigger(event="foo")`):
```
from metaflow.integrations import ArgoEvent

def main():
    evt = ArgoEvent('foo', url="http://localhost:12000/metaflow-event")
    evt.publish(force=True)

if __name__ == '__main__':
    main()
```
