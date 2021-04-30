# Datastore

Stores Metaflow state, acting as Metaflow's remote Datastore. The data stored includes but is not limited:

- for each flow
  - for each version
    - conda environments
    - dependencies
    - artifacts
    - input
    - output

No duplicate data is stored thanks to deduplication.

To read more, see [the Metaflow docs](https://docs.metaflow.org/metaflow-on-aws/metaflow-on-aws#datastore)