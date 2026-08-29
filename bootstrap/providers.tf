provider "aws" {
  region = "eu-central-1"

  default_tags {
    tags = {
      Project   = "thesis"
      ManagedBy = "terraform"
      Role      = "bootstrap-state"
    }
  }
}
