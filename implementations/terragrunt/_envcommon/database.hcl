dependency "network" {
  config_path = "../network"

  mock_outputs = {
    private_subnet_ids = ["subnet-mock-a", "subnet-mock-b"]
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

terraform {
  source = "${dirname(find_in_parent_folders("terragrunt.hcl"))}/../../modules/database"
}

inputs = {
  environment           = include.unit.locals.environment
  region                = include.unit.locals.region
  instance_size         = include.unit.locals.instance_size
  storage_gb            = include.unit.locals.storage_gb
  high_availability     = include.unit.locals.high_availability
  backup_retention_days = include.unit.locals.backup_retention_days
  subnet_ids            = dependency.network.outputs.private_subnet_ids
  tags                  = include.unit.locals.common_tags
}
