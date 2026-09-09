output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role."
  value       = try(aws_iam_role.eks_cluster[0].arn, null)
}

output "eks_cluster_role_name" {
  description = "Name of the EKS cluster IAM role."
  value       = try(aws_iam_role.eks_cluster[0].name, null)
}

output "eks_node_role_arn" {
  description = "ARN of the EKS node IAM role."
  value       = try(aws_iam_role.eks_node[0].arn, null)
}

output "eks_node_role_name" {
  description = "Name of the EKS node IAM role."
  value       = try(aws_iam_role.eks_node[0].name, null)
}

output "load_balancer_role_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM role."
  value       = try(aws_iam_role.load_balancer[0].arn, null)
}

output "external_secrets_role_arn" {
  description = "ARN of the External Secrets IAM role."
  value       = try(aws_iam_role.external_secrets[0].arn, null)
}

output "application_role_arns" {
  description = "Map of application names to IAM role ARNs."
  value = {
    for name, role in aws_iam_role.application :
    name => role.arn
  }
}

output "application_role_names" {
  description = "Map of application names to IAM role names."
  value = {
    for name, role in aws_iam_role.application :
    name => role.name
  }
}

output "pod_identity_role_arns" {
  description = "All IAM role ARNs intended for EKS Pod Identity associations."
  value = merge(
    {
      vpc_cni          = try(aws_iam_role.vpc_cni[0].arn, null)
      ebs_csi          = try(aws_iam_role.ebs_csi[0].arn, null)
      load_balancer    = try(aws_iam_role.load_balancer[0].arn, null)
      external_secrets = try(aws_iam_role.external_secrets[0].arn, null)
    },
    {
      for name, role in aws_iam_role.application :
      name => role.arn
    }
  )
}

output "ebs_csi_role_arn" {
  description = "The ebs csi arn."
  value       = aws_iam_role.ebs_csi.arn
}