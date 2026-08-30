# Four deployments = four thesis units. Isolated state per deployment on HCP.
# Auth follows HashiCorp's AWS Stacks tutorial: identity_token + IAM role ARN.
# https://github.com/hashicorp-education/learn-terraform-stacks-deploy-aws
#
# Env/region tables live in locals (Terragrunt env.hcl / region.hcl analog).
# A deployment block only names the unit and the values that are unique to it.

identity_token "aws" {
  audience = ["aws.workload.identity"]
}

locals {
  # Placeholder: create this IAM role for HCP OIDC; not provisioned in this ticket.
  role_arn = "arn:aws:iam::559338556370:role/thesis-stacks"

  auth = {
    role_arn       = local.role_arn
    identity_token = identity_token.aws.jwt
  }

  env = {
    dev = {
      instance_size         = "small"
      replica_count         = 1
      storage_gb            = 20
      high_availability     = false
      backup_retention_days = 1
      log_retention_days    = 7
      enable_cdn            = false
      app_version           = "1.0.0"
    }
    stage = {
      instance_size         = "medium"
      replica_count         = 2
      storage_gb            = 50
      high_availability     = false
      backup_retention_days = 7
      log_retention_days    = 30
      enable_cdn            = false
      app_version           = "1.0.0"
    }
    prod = {
      instance_size         = "large"
      replica_count         = 4
      storage_gb            = 100
      high_availability     = true
      backup_retention_days = 30
      log_retention_days    = 90
      enable_cdn            = true
      app_version           = "1.0.0"
    }
  }

  region = {
    eu-central-1 = {
      cpu_alarm_threshold = 80
    }
    us-east-1 = {
      cpu_alarm_threshold = 75
    }
  }
}

deployment "dev_eu_central_1" {
  inputs = merge(local.env.dev, local.region["eu-central-1"], local.auth, {
    environment = "dev"
    region      = "eu-central-1"
    vpc_cidr    = "10.10.0.0/16"
  })
}

deployment "stage_eu_central_1" {
  inputs = merge(local.env.stage, local.region["eu-central-1"], local.auth, {
    environment = "stage"
    region      = "eu-central-1"
    vpc_cidr    = "10.20.0.0/16"
  })
}

deployment "prod_eu_central_1" {
  inputs = merge(local.env.prod, local.region["eu-central-1"], local.auth, {
    environment = "prod"
    region      = "eu-central-1"
    vpc_cidr    = "10.30.0.0/16"
  })
}

deployment "prod_us_east_1" {
  inputs = merge(local.env.prod, local.region["us-east-1"], local.auth, {
    environment = "prod"
    region      = "us-east-1"
    vpc_cidr    = "10.31.0.0/16"
  })
}
