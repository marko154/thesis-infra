variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "instance_size" {
  type        = string
  description = "small, medium, or large — maps to EKS node instance type"
}

variable "replica_count" {
  type        = number
  description = "Desired node count in the managed node group"
}

variable "app_version" {
  type        = string
  description = "Application version label applied to the cluster/node group"
}

variable "kubernetes_version" {
  type        = string
  description = "EKS Kubernetes version (AWS standard support)"
  default     = "1.36"
}

variable "subnet_ids" {
  type = list(string)
}

variable "media_bucket_arn" {
  type        = string
  description = "Media bucket the application pods read and write via EKS Pod Identity."
}

variable "tags" {
  type    = map(string)
  default = {}
}
