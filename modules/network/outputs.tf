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
  description = "Security group for the EKS node group (ticket 32 wires RDS to this)."
  value       = aws_security_group.nodes.id
}

output "cluster_security_group_id" {
  description = "Additional security group for the EKS control plane."
  value       = aws_security_group.cluster.id
}

