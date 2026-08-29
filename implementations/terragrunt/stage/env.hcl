locals {
  environment           = "stage"
  instance_size         = "medium"
  replica_count         = 2
  storage_gb            = 50
  high_availability     = false
  backup_retention_days = 7
  log_retention_days    = 30
  enable_cdn            = false
  app_version           = "1.0.0"
}
