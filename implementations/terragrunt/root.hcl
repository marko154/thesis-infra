locals {
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment = local.env_vars.locals.environment
  region      = local.region_vars.locals.region
}

remote_state {
  backend = "s3"

  config = {
    bucket       = "thesis-tfstate-559338556370"
    key          = "terragrunt/${path_relative_to_include()}/terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.region}"
}
EOF
}

inputs = merge(
  local.env_vars.locals,
  local.region_vars.locals,
  {
    domain_name = "${local.environment}.${local.region}.thesis-app.example"
    tags = {
      Environment = local.environment
      Region      = local.region
      ManagedBy   = "thesis-harness"
    }
  },
)
