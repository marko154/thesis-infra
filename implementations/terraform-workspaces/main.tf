module "network" {
  source = "../../modules/network"

  environment = local.environment
  region      = local.region
  vpc_cidr    = local.unit.vpc_cidr
  tags        = local.common_tags
}

module "edge" {
  source = "../../modules/edge"

  environment = local.environment
  region      = local.region
  domain_name = local.domain_name
  enable_cdn  = local.environment == "prod"
  tags        = local.common_tags
}

module "application" {
  source = "../../modules/application"

  environment   = local.environment
  region        = local.region
  instance_size = local.unit.instance_size
  replica_count = local.unit.replica_count
  app_version   = local.unit.app_version
  subnet_ids    = module.network.private_subnet_ids
  tags          = local.common_tags
}

module "database" {
  source = "../../modules/database"

  environment               = local.environment
  region                    = local.region
  instance_size             = local.unit.instance_size
  storage_gb                = local.unit.storage_gb
  high_availability         = local.unit.high_availability
  backup_retention_days     = local.unit.backup_retention_days
  subnet_ids                = module.network.private_subnet_ids
  vpc_id                    = module.network.vpc_id
  allowed_security_group_id = module.application.cluster_security_group_id
  tags                      = local.common_tags
}

module "monitoring" {
  source = "../../modules/monitoring"

  environment         = local.environment
  region              = local.region
  log_retention_days  = local.unit.log_retention_days
  cpu_alarm_threshold = local.unit.cpu_alarm_threshold
  cluster_name        = module.application.cluster_name
  db_identifiers      = module.database.db_identifiers
  tags                = local.common_tags
}
