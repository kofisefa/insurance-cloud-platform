output "cluster_name" {
  description = "EKS Cluster name"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "EKS Cluster endpoint for kubectl"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_arn" {
  value = aws_eks_cluster.this.arn
}

output "cluster_security_group_id" {
  description = "Security group ID of the cluster"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "node_group_role_arn" {
  value = aws_iam_role.node.arn
}