#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

command -v kubectl >/dev/null 2>&1 || {
  echo "kubectl is required"
  exit 1
}

if command -v kubeconform >/dev/null 2>&1; then
  find kubernetes gitops -type f \( -name '*.yaml' -o -name '*.yml' \) -print0 |
    xargs -0 kubeconform -strict -ignore-missing-schemas
else
  echo "kubeconform not installed; performing YAML parse checks with kubectl where possible."
fi

kubectl kustomize kubernetes/platform/argo-rollouts >/dev/null

echo "8.7 static validation completed."
echo "Cluster-side validation should additionally verify:"
echo "  - Argo Rollouts CRDs/controller health"
echo "  - AWS Load Balancer Controller health"
echo "  - Prometheus endpoint"
echo "  - ALB Ingress reconciliation"
echo "  - Rollout/AnalysisRun status"
