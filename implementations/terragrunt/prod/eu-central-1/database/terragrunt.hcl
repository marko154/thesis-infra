include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/database.hcl"
}

inputs = {
  instance_size         = "large"
  storage_gb            = 100
  high_availability     = true
  backup_retention_days = 30
}
