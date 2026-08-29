locals {
  environment           = "dev"
  instance_size         = "small"
  replica_count         = 1
  storage_gb            = 20
  high_availability     = false
  backup_retention_days = 1
  log_retention_days    = 7
  enable_cdn            = false
  app_version           = "1.0.0"
}
