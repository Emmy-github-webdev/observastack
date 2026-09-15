# Terraform Integration Contract

Step 7.6 consumes infrastructure created earlier; it does not recreate the VPC/EKS.

Terraform integration must expose these values to the GitOps/bootstrap layer:

- EKS cluster name
- VPC ID
- region
- subnet IDs or discovery tags
- AWS Load Balancer Controller IAM role ARN
- Pod Identity association
- optional ALB security group ID
- optional ACM certificate ARN

Recommended role name pattern:

`observastack-<environment>-aws-load-balancer-controller`

The IAM policy itself should follow the AWS Load Balancer Controller release policy for the pinned controller version. Review policy changes on controller upgrades.
