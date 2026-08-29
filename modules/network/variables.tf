variable "environment" {
  type        = string
  description = "Deployment environment (dev, stage, prod)."
}

variable "region" {
  type        = string
  description = "AWS region."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all network resources."
  default     = {}
}
