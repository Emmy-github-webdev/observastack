#!/usr/bin/env bash
set -euo pipefail

SERVICE="${1:-}"
FROM_ENV="${2:-}"
TO_ENV="${3:-}"
DIGEST="${4:-}"

VALID_SERVICES=(user-service product-service order-service payment-service)
VALID_ENVS=(dev staging production)

contains() { local needle="$1"; shift; for item in "$@"; do [[ "$item" == "$needle" ]] && return 0; done; return 1; }

contains "$SERVICE" "${VALID_SERVICES[@]}" || { echo "Invalid service: $SERVICE" >&2; exit 2; }
contains "$FROM_ENV" "${VALID_ENVS[@]}" || { echo "Invalid source environment: $FROM_ENV" >&2; exit 2; }
contains "$TO_ENV" "${VALID_ENVS[@]}" || { echo "Invalid target environment: $TO_ENV" >&2; exit 2; }
[[ "$FROM_ENV" != "$TO_ENV" ]] || { echo "Source and target environments must differ" >&2; exit 2; }

case "$FROM_ENV:$TO_ENV" in
  dev:staging|staging:production) ;;
  *) echo "Promotion is only allowed dev->staging or staging->production" >&2; exit 2 ;;
esac

[[ "$DIGEST" =~ ^sha256:[a-f0-9]{64}$ ]] || { echo "Digest must be sha256:<64 lowercase hex characters>" >&2; exit 2; }

FILE="gitops/environments/$TO_ENV/$SERVICE/kustomization.yaml"
[[ -f "$FILE" ]] || { echo "Missing $FILE. Add the service Kustomize contract before promotion." >&2; exit 3; }

python3 - "$FILE" "$DIGEST" <<'PY'
import pathlib, re, sys
path = pathlib.Path(sys.argv[1])
digest = sys.argv[2]
text = path.read_text()
if 'images:' not in text:
    raise SystemExit('kustomization.yaml has no images: section')
# Only replace a digest attached to an image entry; tags are rejected.
pattern = re.compile(r'(newName:\s*579871530627\.dkr\.ecr\.us-east-1\.amazonaws\.com/observastack/[a-z0-9-]+\s*\n\s*newTag:\s*)[^\n]+')
if pattern.search(text):
    raise SystemExit('Found newTag; promotion requires an immutable digest field.')
pattern = re.compile(r'(digest:\s*)sha256:[0-9a-f]{64}')
new_text, count = pattern.subn(r'\g<1>' + digest, text, count=1)
if count != 1:
    raise SystemExit('Expected exactly one existing digest field in the target kustomization.')
path.write_text(new_text)
PY

git diff -- "$FILE"
