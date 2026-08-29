locals {
  environment           = "dev"
  region                = "eu-central-1"
  vpc_cidr              = "10.10.0.0/16"
  replica_count         = 1
  instance_size         = "small"
  app_version           = "1.0.0"
  storage_gb            = 20
  high_availability     = false
  backup_retention_days = 1
  log_retention_days    = 7
  cpu_alarm_threshold   = 80
  domain_name           = "dev.eu-central-1.thesis-app.example"
  enable_cdn            = false

  common_tags = {
    Environment = local.environment
    Region      = local.region
    ManagedBy   = "thesis-harness"
  }
}
