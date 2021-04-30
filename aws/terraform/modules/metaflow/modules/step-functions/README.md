# Step Functions

This module sets up the usage of AWS Step Functions. While this module is related to the `computation` module in the 
sense that both provide remote computation, they are different in both their intent and use cases. 

For pure rapid experimentation, data scientists will generally find using AWS Batch through the `computation` 
module to be more efficient. Once a data scientist has a flow that is ready for production or takes a very long time 
to run, they may find that leveraging this module to be beneficial. This is for two reasons:

1. This module handles orchestration for you, while the `computation` module relies on the data scientist's computer 
   for this. This is especially useful for long-running flows as you'll no longer rely on your local machine 
   being awake and having a consistent internet connection.
2. This module's executions can be scheduled. When one has a flow that they'd like to run using a cron this module's 
   usage of step functions allows one to schedule executions.

To read more, see 
[the Metaflow docs](https://docs.metaflow.org/going-to-production-with-metaflow/scheduling-metaflow-flows)
