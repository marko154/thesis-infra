dependency "application" {
  config_path = "../application"

  mock_outputs = {
    cluster_name = "thesis-mock-app"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

terraform {
  source = "${dirname(find_in_parent_folders("terragrunt.hcl"))}/../../modules/monitoring"
}

inputs = {
  environment         = include.unit.locals.environment
  region              = include.unit.locals.region
  log_retention_days  = include.unit.locals.log_retention_days
  cpu_alarm_threshold = include.unit.locals.cpu_alarm_threshold
  cluster_name        = dependency.application.outputs.cluster_name
  tags                = include.unit.locals.common_tags
}
