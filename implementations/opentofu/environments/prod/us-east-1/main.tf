module "settings" {
  source = "../../../_shared"

  environment = "prod"
  region      = "us-east-1"
}

module "network" {
  source = "../../../../../modules/network"

  environment = module.settings.environment
  region      = module.settings.region
  vpc_cidr    = module.settings.vpc_cidr
  tags        = module.settings.common_tags
}

module "edge" {
  source = "../../../../../modules/edge"

  environment = module.settings.environment
  region      = module.settings.region
  domain_name = module.settings.domain_name
  enable_cdn  = module.settings.enable_cdn
  tags        = module.settings.common_tags
}

module "application" {
  source = "../../../../../modules/application"

  environment   = module.settings.environment
  region        = module.settings.region
  instance_size = module.settings.instance_size
  replica_count = module.settings.replica_count
  app_version   = module.settings.app_version
  subnet_ids    = module.network.private_subnet_ids
  tags          = module.settings.common_tags
}

module "database" {
  source = "../../../../../modules/database"

  environment           = module.settings.environment
  region                = module.settings.region
  instance_size         = module.settings.instance_size
  storage_gb            = module.settings.storage_gb
  high_availability     = module.settings.high_availability
  backup_retention_days = module.settings.backup_retention_days
  subnet_ids            = module.network.private_subnet_ids
  tags                  = module.settings.common_tags
}

module "monitoring" {
  source = "../../../../../modules/monitoring"

  environment         = module.settings.environment
  region              = module.settings.region
  log_retention_days  = module.settings.log_retention_days
  cpu_alarm_threshold = module.settings.cpu_alarm_threshold
  cluster_name        = module.application.cluster_name
  tags                = module.settings.common_tags
}
