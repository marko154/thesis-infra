include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/application.hcl"
}

inputs = {
  instance_size = "medium"
  replica_count = 2
}
