data "aws_caller_identity" "current" {}

locals {
  bucket_name = "thesis-tfstate-${data.aws_caller_identity.current.account_id}"
}
