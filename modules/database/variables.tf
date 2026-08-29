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

variable "tags" {
  type    = map(string)
  default = {}
}
