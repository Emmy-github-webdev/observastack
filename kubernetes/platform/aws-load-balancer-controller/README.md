# AWS Load Balancer Controller

This directory is the GitOps boundary for the AWS Load Balancer Controller.

Recommended production deployment:
- Helm chart
- pinned chart version
- environment-specific values
- ServiceAccount managed by the chart
- IAM supplied through EKS Pod Identity
- Argo CD as deployment authority

Do not add an `eks.amazonaws.com/role-arn` annotation when using EKS Pod Identity.

The concrete HelmRelease example is kept separate from the Kustomize base because HelmRelease is not a built-in Kubernetes API object and requires the selected GitOps controller's CRDs.
