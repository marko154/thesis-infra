dependency "network" {
  config_path = "../network"

  mock_outputs = {
    private_subnet_ids = ["subnet-mock-a", "subnet-mock-b"]
    vpc_id             = "vpc-mock"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

dependency "application" {
  config_path = "../application"

  mock_outputs = {
    cluster_security_group_id = "sg-mock-cluster"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../..//modules/database"
}

inputs = {
  subnet_ids                = dependency.network.outputs.private_subnet_ids
  vpc_id                    = dependency.network.outputs.vpc_id
  allowed_security_group_id = dependency.application.outputs.cluster_security_group_id
}
