# Same shared modules as the other approaches. Plan/apply require HCP Terraform;
# local CLI supports stacks init / validate / fmt.
#
# Docs: https://developer.hashicorp.com/terraform/language/stacks
# Auth: https://github.com/hashicorp-education/learn-terraform-stacks-deploy-aws

required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 6.0"
  }
}

provider "aws" "this" {
  config {
    region = var.region

    assume_role_with_web_identity {
      role_arn           = var.role_arn
      web_identity_token = var.identity_token
    }
  }
}
