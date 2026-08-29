variable "environment" {
  type = string
}

variable "region" {
  type = string
}

locals {
  env_config = {
    dev = {
      replica_count         = 1
      instance_size         = "small"
      app_version           = "1.0.0"
      storage_gb            = 20
      high_availability     = false
      backup_retention_days = 1
      log_retention_days    = 7
    }
    stage = {
      replica_count         = 2
      instance_size         = "medium"
      app_version           = "1.0.0"
      storage_gb            = 50
      high_availability     = false
      backup_retention_days = 7
      log_retention_days    = 30
    }
    prod = {
      replica_count         = 4
      instance_size         = "large"
      app_version           = "1.0.0"
      storage_gb            = 100
      high_availability     = true
      backup_retention_days = 30
      log_retention_days    = 90
    }
  }

  vpc_cidrs = {
    "dev-eu-central-1"     = "10.10.0.0/16"
    "stage-eu-central-1"   = "10.20.0.0/16"
    "prod-eu-central-1"    = "10.30.0.0/16"
    "prod-us-east-1"       = "10.31.0.0/16"
  }

  unit_key = "${var.environment}-${var.region}"
  unit     = local.env_config[var.environment]

  common_tags = {
    Environment = var.environment
    Region      = var.region
    ManagedBy   = "thesis-harness"
  }
}

output "environment" {
  value = var.environment
}

output "region" {
  value = var.region
}

output "vpc_cidr" {
  value = local.vpc_cidrs[local.unit_key]
}

output "replica_count" {
  value = local.unit.replica_count
}

output "instance_size" {
  value = local.unit.instance_size
}

output "app_version" {
  value = local.unit.app_version
}

output "storage_gb" {
  value = local.unit.storage_gb
}

output "high_availability" {
  value = local.unit.high_availability
}

output "backup_retention_days" {
  value = local.unit.backup_retention_days
}

output "log_retention_days" {
  value = local.unit.log_retention_days
}

output "cpu_alarm_threshold" {
  value = var.region == "us-east-1" ? 75 : 80
}

output "domain_name" {
  value = "${var.environment}.${var.region}.thesis-app.example"
}

output "enable_cdn" {
  value = var.environment == "prod"
}

output "common_tags" {
  value = local.common_tags
}
