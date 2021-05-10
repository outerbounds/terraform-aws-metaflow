# README

This project is composed of modules which break up the responsibility into logical parts. See each module's 
corresponding `README.md` for more details.

Provides the core functionality for Metaflow which includes:

- on demand processing (`computation`)
- blob and tabular storage (`datastore`)
- an API to record and query past executions (`metadata-service`)
- orchestrated processing (`step-functions`)

Depends on a VPC that has been previously set up. The output of the project `infra` is an example 
configuration of a VPC that can be passed to this module.

## ECR

Sets up an AWS ECR to hold the Docker image we wish to use with Metaflow.
