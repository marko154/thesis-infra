terraform {
  source = "${dirname(find_in_parent_folders("terragrunt.hcl"))}/../../modules/edge"
}

inputs = {
  environment = include.unit.locals.environment
  region      = include.unit.locals.region
  domain_name = include.unit.locals.domain_name
  enable_cdn  = include.unit.locals.enable_cdn
  tags        = include.unit.locals.common_tags
}
