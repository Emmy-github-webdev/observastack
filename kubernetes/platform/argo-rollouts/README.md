# Argo Rollouts Controller

This platform component enables `argoproj.io/Rollout`, `AnalysisTemplate`, `AnalysisRun`, and related progressive-delivery resources.

Pinned release: **v1.10.0**.

Install through the Kustomization after validating the pinned upstream release in a non-production cluster.

The upstream release asset is:
`https://github.com/argoproj/argo-rollouts/releases/download/v1.10.0/install.yaml`

Release asset SHA-256 observed upstream:
`ca8a1785391026023627c8a12db5422e227d7a7a6ec7c01f99f7d5b1726ed53c`

The controller is cluster-scoped. Treat its installation and upgrades as platform changes.
