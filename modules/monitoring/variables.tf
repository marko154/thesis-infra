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
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
