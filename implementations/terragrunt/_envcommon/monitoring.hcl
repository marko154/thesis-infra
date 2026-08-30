dependency "application" {
  config_path = "../application"

  mock_outputs = {
    cluster_name = "thesis-mock-app"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

dependency "database" {
  config_path = "../database"

  mock_outputs = {
    db_identifiers = {
      users     = "thesis-mock-users"
      metadata  = "thesis-mock-metadata"
      favorites = "thesis-mock-favorites"
    }
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../..//modules/monitoring"
}

inputs = {
  cluster_name   = dependency.application.outputs.cluster_name
  db_identifiers = dependency.database.outputs.db_identifiers
}
