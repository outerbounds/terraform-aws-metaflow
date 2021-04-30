# README

This project is composed of modules which break up the responsibility into logical parts. See each module's 
corresponding `README.md` for more details.

Provides the core functionality for Metaflow which includes:

- on demand processing (`computation`)
- blob and tabular storage (`datastore`)
- an API to record and query past executions (`metadata-service`)
- orchestrated processing (`step-functions`)

Depends on the output of the project `infra`.

## ECR

Sets up an AWS ECR to hold the Docker image we wish to use with Metaflow.
