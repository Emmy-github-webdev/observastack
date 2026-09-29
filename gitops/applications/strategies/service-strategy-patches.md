# Strategy Patches

Do not deploy all three strategy examples for the same service.

Choose one workload type:

- `Deployment` for RollingUpdate
- `Rollout` with `blueGreen` for Blue-Green
- `Rollout` with `canary` for progressive delivery

The generated Application should point to the service directory containing exactly the selected workload.

Recommended repository shape:

```text
gitops/environments/
├── dev/
│   └── user-service/
│       ├── kustomization.yaml
│       └── deployment.yaml
├── staging/
│   └── user-service/
│       └── ...
└── production/
    └── user-service/
        ├── kustomization.yaml
        ├── rollout.yaml
        ├── services.yaml
        ├── ingress.yaml
        └── analysis.yaml
```
