# GitOps Bootstrap

This directory is the root of the Argo CD bootstrap process.

Recommended order:

1. create/verify `argocd` namespace;
2. install pinned Argo CD HA release;
3. configure repository authentication;
4. apply AppProjects;
5. apply bootstrap Applications/ApplicationSets;
6. verify sync and health;
7. allow Argo CD to reconcile the remaining GitOps tree.

Do not place plaintext credentials here.
