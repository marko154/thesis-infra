include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

include "unit" {
  path = find_in_parent_folders("unit.hcl")
}

include "stack" {
  path = "${dirname(find_in_parent_folders("terragrunt.hcl"))}/_envcommon/edge.hcl"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<PROVIDER
provider "aws" {
  region = "${include.unit.locals.region}"
}
PROVIDER
}
