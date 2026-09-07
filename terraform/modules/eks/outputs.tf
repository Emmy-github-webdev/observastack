output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.observastack_eks_cluster.name
}

output "cluster_arn" {
  description = "EKS cluster ARN."
  value       = aws_eks_cluster.observastack_eks_cluster.arn
}

output "cluster_endpoint" {
  description = "EKS Kubernetes API endpoint."
  value       = aws_eks_cluster.observastack_eks_cluster.endpoint
}

output "cluster_version" {
  description = "Kubernetes version."
  value       = aws_eks_cluster.observastack_eks_cluster.version
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded Kubernetes cluster CA data."
  value       = aws_eks_cluster.observastack_eks_cluster.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "EKS cluster security group ID."
  value       = aws_eks_cluster.observastack_eks_cluster.vpc_config[0].cluster_security_group_id
}

output "node_group_name" {
  description = "Default managed node group name."
  value       = aws_eks_node_group.system.node_group_name
}

output "node_group_arn" {
  description = "Default managed node group ARN."
  value       = aws_eks_node_group.system.arn
}