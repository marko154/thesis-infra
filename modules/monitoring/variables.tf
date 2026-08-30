variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "log_retention_days" {
  type = number
}

variable "cpu_alarm_threshold" {
  type = number
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name, used only to stamp the log group we own."
}

variable "db_identifiers" {
  type        = map(string)
  description = "Map of service name → RDS identifier for CPU alarms."
}

variable "tags" {
  type    = map(string)
  default = {}
}
