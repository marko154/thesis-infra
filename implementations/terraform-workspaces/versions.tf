terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket               = "thesis-tfstate-559338556370"
    key                  = "terraform.tfstate"
    workspace_key_prefix = "workspaces"
    region               = "eu-central-1"
    encrypt              = true
    use_lockfile         = true
  }
}
