terraform {
  source = "${dirname(find_in_parent_folders("terragrunt.hcl"))}/../../modules/network"
}

inputs = {
  environment = include.unit.locals.environment
  region      = include.unit.locals.region
  vpc_cidr    = include.unit.locals.vpc_cidr
  tags        = include.unit.locals.common_tags
}
