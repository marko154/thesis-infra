include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/monitoring.hcl"
}

inputs = {
  log_retention_days = 30
}
