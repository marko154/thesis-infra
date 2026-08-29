variable "environment" {
  type = string
}

variable "region" {
  type = string
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
