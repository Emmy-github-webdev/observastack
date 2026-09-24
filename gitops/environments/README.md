# GitOps Environments

Environment directories represent desired state.

```text
dev/
staging/
production/
```

Promotion should update environment-specific image references/configuration through reviewed Git changes.

Production should use immutable image digests and an explicit approval/synchronization path.
