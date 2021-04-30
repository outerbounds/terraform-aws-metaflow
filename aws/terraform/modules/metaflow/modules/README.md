# Modules

Our Metaflow Terraform code has been separated into separate modules based on the service architecture.

## Computation

Sets up remote computation resources so flows can be run on EC2 instances. These resources do not perform 
orchestration and rely on the data scientist's computer to perform this coordination.

## Datastore

Sets up blob and tabular data storage. Records all flows, the steps they took, their conda environments, artifacts 
and results.

Should exist for the lifetime of the stack.

## Metadata Service

Sets up an API entrypoint to interact with all other services, both for running flows and interacting with the 
Datastore to explore historic runs.

## Step Functions

Sets up remote computation resources that come with orchestration. This allows data scientists to schedule flows 
using crons as well as being able to kick off flows and shut down their machine, as the remote resources will handle 
all coordination.