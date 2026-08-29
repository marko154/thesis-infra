# Four deployments = four thesis deployment units.
# Each deployment has isolated state in HCP Terraform.

deployment "dev_eu_central_1" {
  inputs = {
    environment             = "dev"
    region                  = "eu-central-1"
    vpc_cidr                = "10.10.0.0/16"
    replica_count           = 1
    instance_size           = "small"
    app_version             = "1.0.0"
    storage_gb              = 20
    high_availability       = false
    backup_retention_days   = 1
    log_retention_days      = 7
    cpu_alarm_threshold     = 80
    domain_name             = "dev.eu-central-1.thesis-app.example"
    enable_cdn              = false
  }
}

deployment "stage_eu_central_1" {
  inputs = {
    environment             = "stage"
    region                  = "eu-central-1"
    vpc_cidr                = "10.20.0.0/16"
    replica_count           = 2
    instance_size           = "medium"
    app_version             = "1.0.0"
    storage_gb              = 50
    high_availability       = false
    backup_retention_days   = 7
    log_retention_days      = 30
    cpu_alarm_threshold     = 80
    domain_name             = "stage.eu-central-1.thesis-app.example"
    enable_cdn              = false
  }
}

deployment "prod_eu_central_1" {
  inputs = {
    environment             = "prod"
    region                  = "eu-central-1"
    vpc_cidr                = "10.30.0.0/16"
    replica_count           = 4
    instance_size           = "large"
    app_version             = "1.0.0"
    storage_gb              = 100
    high_availability       = true
    backup_retention_days   = 30
    log_retention_days      = 90
    cpu_alarm_threshold     = 80
    domain_name             = "prod.eu-central-1.thesis-app.example"
    enable_cdn              = true
  }
}

deployment "prod_us_east_1" {
  inputs = {
    environment             = "prod"
    region                  = "us-east-1"
    vpc_cidr                = "10.31.0.0/16"
    replica_count           = 4
    instance_size           = "large"
    app_version             = "1.0.0"
    storage_gb              = 100
    high_availability       = true
    backup_retention_days   = 30
    log_retention_days      = 90
    cpu_alarm_threshold     = 75
    domain_name             = "prod.us-east-1.thesis-app.example"
    enable_cdn              = true
  }
}
