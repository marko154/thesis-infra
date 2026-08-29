include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path = "${dirname(find_in_parent_folders("root.hcl"))}/_envcommon/network.hcl"
}

inputs = {
  vpc_cidr = "10.31.0.0/16"
}
