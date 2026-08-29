dependency "network" {
  config_path = "../network"

  mock_outputs = {
    private_subnet_ids = ["subnet-mock-a", "subnet-mock-b"]
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../../modules/database"
}

inputs = {
  subnet_ids = dependency.network.outputs.private_subnet_ids
}
