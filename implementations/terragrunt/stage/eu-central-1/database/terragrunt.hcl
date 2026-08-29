include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/database.hcl"
}

inputs = {
  instance_size         = "medium"
  storage_gb            = 50
  backup_retention_days = 7
}
