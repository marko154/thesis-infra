variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "instance_size" {
  type = string
}

variable "storage_gb" {
  type = number
}

variable "high_availability" {
  type = bool
}

variable "backup_retention_days" {
  type = number
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type        = string
  description = "VPC that hosts the instances and the RDS security group."
}

variable "allowed_security_group_id" {
  type        = string
  description = "Security group allowed to reach PostgreSQL (EKS cluster SG; managed nodes are members)."
}

variable "tags" {
  type    = map(string)
  default = {}
}
