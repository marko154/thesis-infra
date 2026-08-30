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

variable "high_availability" {
  type        = bool
  description = "When true, run one NAT gateway per availability zone so a zone failure cannot strand egress for the surviving zone. Non-prod runs a single NAT to avoid the per-hour charge."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all network resources."
  default     = {}
}
