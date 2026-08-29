dependency "application" {
  config_path = "../application"

  mock_outputs = {
    cluster_name = "thesis-mock-app"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../../modules/monitoring"
}

inputs = {
  cluster_name = dependency.application.outputs.cluster_name
}
