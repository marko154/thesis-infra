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

variable "db_storage_gb" {
  type        = number
  description = "Allocated storage per RDS instance, used to derive the free-storage threshold."
}

variable "db_instance_size" {
  type        = string
  description = "small, medium, or large — sets the connection ceiling the connection alarm is measured against."
}

variable "free_storage_threshold_percent" {
  type        = number
  description = "Alarm when free storage drops below this percentage of allocated storage."
  default     = 20
}

variable "alarm_email" {
  type        = string
  description = "Address subscribed to the alarm topic."
  default     = "ops@thesis-app.example"
}

variable "tags" {
  type    = map(string)
  default = {}
}
