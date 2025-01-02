###############################################################################
# An example using this module to set up a minimal deployment Metaflow
# with AWS Batch support, without the UI.
###############################################################################

terraform {
  required_version = ">= 1.10"

  required_providers {
    aws    = ">= 5.82"
    random = ">= 3.6"
  }
}

provider "aws" {
  region = "us-west-2" # make sure to set the region to the one you want to deploy to
}


module "metaflow" {
  source = "../../"

  create_vpc = true

  tags = {
    "managedBy" = "terraform"
  }
}

# The module will generate a Metaflow config in JSON format, write it to a file
resource "local_file" "metaflow_config" {
  content  = module.metaflow.metaflow_aws_managed_profile_json
  filename = "./metaflow_profile.json"
}
