#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail=0
check_file() { [[ -f "$1" ]] || { echo "ERROR missing: $1"; fail=1; }; }
check_file gitops/applications/services-applicationset.yaml
check_file gitops/projects/observastack-applications.yaml
check_file gitops/projects/observastack-production.yaml
check_file scripts/promote-image.sh
check_file scripts/rollback.sh

python3 <<'PY' || fail=1
from pathlib import Path
import re
try:
    import yaml
except ImportError:
    print('ERROR: PyYAML is required for static validation')
    raise SystemExit(1)

for p in Path('gitops').rglob('*.yaml'):
    try:
        docs=list(yaml.safe_load_all(p.read_text()))
    except Exception as e:
        print(f'ERROR YAML {p}: {e}')
        raise SystemExit(1)

appset=Path('gitops/applications/services-applicationset.yaml').read_text()
if 'observastack-services-production' not in appset:
    print('ERROR: production ApplicationSet missing')
    raise SystemExit(1)
prod=next(x for x in yaml.safe_load_all(appset) if x and x.get('metadata',{}).get('name')=='observastack-services-production')
if prod['spec']['template']['spec'].get('syncPolicy',{}).get('automated'):
    print('ERROR: production ApplicationSet must not enable automated sync')
    raise SystemExit(1)

for p in Path('gitops').rglob('*.yaml'):
    t=p.read_text()
    if 'Force=true' in t or 'Replace=true' in t:
        print(f'ERROR dangerous sync option in {p}')
        raise SystemExit(1)

projects={p.name: p for p in Path('gitops/projects').glob('*.yaml')}
for name,path in projects.items():
    docs=list(yaml.safe_load_all(path.read_text()))
    for doc in docs:
        if not doc or doc.get('kind') != 'AppProject':
            continue
        repos=doc.get('spec',{}).get('sourceRepos',[])
        if repos and repos != ['https://github.com/Emmy-github-webdev/observastack.git']:
            print(f'ERROR: unexpected source repository in {name}')
            raise SystemExit(1)
        for dest in doc.get('spec',{}).get('destinations',[]):
            if dest.get('namespace') == 'argocd':
                print(f'ERROR: project must not target argocd namespace: {name}')
                raise SystemExit(1)

# Validate the explicit 12-service/environment ApplicationSet contract.
appset_docs=list(yaml.safe_load_all(Path('gitops/applications/services-applicationset.yaml').read_text()))
prod_doc=next(x for x in appset_docs if x and x.get('metadata',{}).get('name')=='observastack-services-production')
normal_doc=next(x for x in appset_docs if x and x.get('metadata',{}).get('name')=='observastack-services')
expected_services={'user-service','product-service','order-service','payment-service'}
normal_entries=normal_doc['spec']['generators'][0]['list']['elements']
prod_entries=prod_doc['spec']['generators'][0]['list']['elements']
if len(normal_entries) != 8 or len(prod_entries) != 4:
    print('ERROR: expected 8 non-production and 4 production ApplicationSet entries')
    raise SystemExit(1)
if {x['service'] for x in normal_entries} != expected_services or {x['service'] for x in prod_entries} != expected_services:
    print('ERROR: ApplicationSet service matrix is incomplete')
    raise SystemExit(1)

print('Static GitOps validation passed')
PY

if command -v kustomize >/dev/null 2>&1; then
  while IFS= read -r d; do
    [[ -f "$d/kustomization.yaml" ]] && kustomize build "$d" >/dev/null
  done < <(find gitops/environments -type d 2>/dev/null)
  echo 'Kustomize builds passed for available environment directories'
else
  echo 'INFO: kustomize not installed; skipped build validation'
fi

bash -n scripts/promote-image.sh scripts/rollback.sh

exit "$fail"
