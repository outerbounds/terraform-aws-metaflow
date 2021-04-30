# Metadata Service

The Metadata Services exposes an API that our local computers interact with. This allows us to transmit data we wish
the Metadata Service to send to our Datastore for storage. Additionally, this is how we will request remote AWS
Batch Jobs to be started as well as how we interrogate the Datastore for historical flow information.

Our current implementation only accepts traffic originating from the Turner VPN. Services internal to AWS can 
access the load balancer used by the API.

To read more, see [the Metaflow docs](https://docs.metaflow.org/metaflow-on-aws/metaflow-on-aws#metadata)