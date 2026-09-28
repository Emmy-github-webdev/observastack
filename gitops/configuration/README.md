# Applying Configuration

After Argo CD CRDs exist:

```bash
kubectl apply -f gitops/projects/
kubectl apply -k kubernetes/platform/argocd
```

Repository credentials must be provisioned separately.

Verify:

```bash
kubectl -n argocd get appprojects
kubectl -n argocd get configmap argocd-cm argocd-rbac-cm argocd-cmd-params-cm
```
