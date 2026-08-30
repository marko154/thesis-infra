output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "vpc_cidr" {
  value = aws_vpc.this.cidr_block
}

output "node_security_group_id" {
  description = "Additional node security group. Managed node groups do not use it without a launch template; RDS ingress uses the EKS cluster SG instead."
  value       = aws_security_group.nodes.id
}

output "cluster_security_group_id" {
  description = "Additional security group for the EKS control plane."
  value       = aws_security_group.cluster.id
}

