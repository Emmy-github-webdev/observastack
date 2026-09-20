# External Secrets Operator Platform

Install ESO using a pinned Helm/GitOps deployment. Step 8 will add the Argo CD Application.

Do not put HelmRelease or Argo CD CRDs in `kubernetes/base`.

Never commit generated secret values.
