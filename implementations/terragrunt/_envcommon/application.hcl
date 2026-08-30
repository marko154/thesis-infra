dependency "network" {
  config_path = "../network"

  mock_outputs = {
    private_subnet_ids = ["subnet-mock-a", "subnet-mock-b"]
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

dependency "edge" {
  config_path = "../edge"

  mock_outputs = {
    media_bucket_arn = "arn:aws:s3:::thesis-mock-media"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/../..//modules/application"
}

inputs = {
  subnet_ids       = dependency.network.outputs.private_subnet_ids
  media_bucket_arn = dependency.edge.outputs.media_bucket_arn
}
