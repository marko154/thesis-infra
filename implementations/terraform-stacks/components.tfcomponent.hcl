locals {
  domain_name = "${var.environment}.${var.region}.thesis-app.example"
  common_tags = {
    Environment = var.environment
    Region      = var.region
    ManagedBy   = "thesis-harness"
  }
}

component "network" {
  source = "../../modules/network"

  inputs = {
    environment = var.environment
    region      = var.region
    vpc_cidr    = var.vpc_cidr
    tags        = local.common_tags
  }

  providers = {
    aws = provider.aws.this
  }
}

component "edge" {
  source = "../../modules/edge"

  inputs = {
    environment = var.environment
    region      = var.region
    domain_name = local.domain_name
    enable_cdn  = var.enable_cdn
    tags        = local.common_tags
  }

  providers = {
    aws = provider.aws.this
  }
}

component "application" {
  source = "../../modules/application"

  inputs = {
    environment   = var.environment
    region        = var.region
    instance_size = var.instance_size
    replica_count = var.replica_count
    app_version   = var.app_version
    subnet_ids    = component.network.private_subnet_ids
    tags          = local.common_tags
  }

  providers = {
    aws = provider.aws.this
  }
}

component "database" {
  source = "../../modules/database"

  inputs = {
    environment               = var.environment
    region                    = var.region
    instance_size             = var.instance_size
    storage_gb                = var.storage_gb
    high_availability         = var.high_availability
    backup_retention_days     = var.backup_retention_days
    subnet_ids                = component.network.private_subnet_ids
    vpc_id                    = component.network.vpc_id
    allowed_security_group_id = component.application.cluster_security_group_id
    tags                      = local.common_tags
  }

  providers = {
    aws = provider.aws.this
  }
}

component "monitoring" {
  source = "../../modules/monitoring"

  inputs = {
    environment         = var.environment
    region              = var.region
    log_retention_days  = var.log_retention_days
    cpu_alarm_threshold = var.cpu_alarm_threshold
    cluster_name        = component.application.cluster_name
    db_identifiers      = component.database.db_identifiers
    tags                = local.common_tags
  }

  providers = {
    aws = provider.aws.this
  }
}
