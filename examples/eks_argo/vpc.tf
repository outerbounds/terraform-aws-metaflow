
# Use existing VPC instead of creating new one
data "aws_vpc" "existing" {
  id = "vpc-01195e9922f40d28d"
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
}

data "aws_subnet" "all_subnets" {
  for_each = toset(data.aws_subnets.all.ids)
  id       = each.value
}

# For now, we'll use all subnets as private since none have public IP mapping
# This may need adjustment based on your specific requirements
locals {
  # Using first two subnets for private (spread across AZs)
  private_subnet_ids = [
    "subnet-06d24ca1cdc68006b",  # us-west-2a
    "subnet-0b9f28860c7718324"   # us-west-2b  
  ]
  # Using last two subnets as "public" (though they're actually private)
  public_subnet_ids = [
    "subnet-0037943db9c00ae6a",  # us-west-2a
    "subnet-01922add8c95526d7"   # us-west-2b
  ]
}
