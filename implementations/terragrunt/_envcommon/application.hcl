dependency "network" {
  config_path = "../network"

  mock_outputs = {
    private_subnet_ids = ["subnet-mock-a", "subnet-mock-b"]
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../../modules/application"
}

inputs = {
  instance_size = "small"
  replica_count = 1
  app_version   = "1.0.0"
  subnet_ids    = dependency.network.outputs.private_subnet_ids
}
