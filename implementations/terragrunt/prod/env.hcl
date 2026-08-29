locals {
  environment           = "prod"
  instance_size         = "large"
  replica_count         = 4
  storage_gb            = 100
  high_availability     = true
  backup_retention_days = 30
  log_retention_days    = 90
  enable_cdn            = true
  app_version           = "1.0.0"
}
