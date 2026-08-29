locals {
  modules_path = "${dirname(find_in_parent_folders("terragrunt.hcl"))}/../../modules"
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

generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
EOF
}
