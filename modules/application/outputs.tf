output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_security_group_id" {
  description = "EKS-created cluster security group; attached to managed nodes."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_arn" {
  value = aws_eks_cluster.this.arn
}

output "node_group_name" {
  value = aws_eks_node_group.this.node_group_name
}

output "node_group_arn" {
  value = aws_eks_node_group.this.arn
}

output "app_role_arn" {
  description = "Role assumed by application pods through EKS Pod Identity."
  value       = aws_iam_role.app.arn
}

output "app_service_account" {
  description = "Namespace and service account the pod identity association binds to."
  value       = "${local.app_namespace}/${local.app_service_account}"
}
