variable "environment" {
  type        = string
  description = "Deployment environment (dev, stage, prod)."
}

variable "region" {
  type        = string
  description = "AWS region for this deployment."
}

variable "vpc_cidr" {
  type = string
}

variable "replica_count" {
  type = number
}

variable "instance_size" {
  type = string
}

variable "app_version" {
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

variable "log_retention_days" {
  type = number
}

variable "cpu_alarm_threshold" {
  type = number
}

variable "domain_name" {
  type = string
}

variable "enable_cdn" {
  type = bool
}
