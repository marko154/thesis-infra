# Thesis reference scenario — Terraform Stacks sketch
#
# Same shared modules as the other approaches. Deployments map 1:1 to
# deployment units (dev/stage/prod × regions). Plan/apply require HCP Terraform;
# local CLI supports stacks init / validate / fmt only.
#
# Docs: https://developer.hashicorp.com/terraform/language/stacks

required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 5.0"
  }
}

provider "aws" "this" {
  config {
    region = var.region

    # For real HCP plans, wire OIDC (identity_token in tfdeploy + assume_role_with_web_identity)
    # or an HCP variable set for static credentials. Left minimal for local validate / structure feel.
  }
}
