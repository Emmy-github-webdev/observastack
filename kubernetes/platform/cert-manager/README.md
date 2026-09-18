# cert-manager Platform

Reusable Kubernetes-side contract for cert-manager.

Expected components:
- cert-manager controller
- webhook
- cainjector
- dedicated ServiceAccount
- EKS Pod Identity association
- ClusterIssuer resources

Install cert-manager through the chosen pinned Helm/GitOps mechanism. Do not place HelmRelease/Argo CD CRDs in the Kubernetes base.
