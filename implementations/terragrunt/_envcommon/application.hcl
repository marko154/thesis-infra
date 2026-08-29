dependency "network" {
  config_path = "../network"

  mock_outputs = {
    private_subnet_ids = ["subnet-mock-a", "subnet-mock-b"]
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

terraform {
  source = "${dirname(find_in_parent_folders("terragrunt.hcl"))}/../../modules/application"
}

inputs = {
  environment   = include.unit.locals.environment
  region        = include.unit.locals.region
  instance_size = include.unit.locals.instance_size
  replica_count = include.unit.locals.replica_count
  app_version   = include.unit.locals.app_version
  subnet_ids    = dependency.network.outputs.private_subnet_ids
  tags          = include.unit.locals.common_tags
}
