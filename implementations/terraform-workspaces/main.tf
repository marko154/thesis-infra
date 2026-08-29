locals {
  common_tags = {
    Environment = var.environment
    Region      = var.region
    ManagedBy   = "thesis-harness"
  }

  domain_name = "${var.environment}.${var.region}.thesis-app.example"
}

module "network" {
  source = "../../modules/network"

  environment = var.environment
  region      = var.region
  vpc_cidr    = var.vpc_cidr
  tags        = local.common_tags
}

module "edge" {
  source = "../../modules/edge"

  environment = var.environment
  region      = var.region
  domain_name = local.domain_name
  enable_cdn  = var.environment == "prod"
  tags        = local.common_tags
}

module "application" {
  source = "../../modules/application"

  environment   = var.environment
  region        = var.region
  instance_size = var.instance_size
  replica_count = var.replica_count
  app_version   = var.app_version
  subnet_ids    = module.network.private_subnet_ids
  tags          = local.common_tags
}

module "database" {
  source = "../../modules/database"

  environment           = var.environment
  region                = var.region
  instance_size         = var.instance_size
  storage_gb            = var.storage_gb
  high_availability     = var.high_availability
  backup_retention_days = var.backup_retention_days
  subnet_ids            = module.network.private_subnet_ids
  tags                  = local.common_tags
}

module "monitoring" {
  source = "../../modules/monitoring"

  environment         = var.environment
  region              = var.region
  log_retention_days  = var.log_retention_days
  cpu_alarm_threshold = var.cpu_alarm_threshold
  cluster_name        = module.application.cluster_name
  tags                = local.common_tags
}
