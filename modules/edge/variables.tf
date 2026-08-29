variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "domain_name" {
  type        = string
  description = "Public zone name for this deployment unit (e.g. dev.eu-central-1.thesis-app.example)."
}

variable "enable_cdn" {
  type        = bool
  description = "When true, provision CloudFront in front of the media bucket and a cdn. DNS record. Intended for prod only."
  default     = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
