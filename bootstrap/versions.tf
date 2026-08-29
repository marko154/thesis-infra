terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Chicken-and-egg: this root creates the bucket the OSS approaches
  # use. Local state here is bootstrap, not a comparison layout.
  backend "local" {
    path = "terraform.tfstate"
  }
}
