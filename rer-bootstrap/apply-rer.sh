#!/bin/sh
set -euo pipefail
export LC_ALL=C LANG=C

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PAY_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
REPO_ROOT="${1:-.}"

mkdir -p "$REPO_ROOT/contract" "$REPO_ROOT/tests"          "$REPO_ROOT/.github/workflows" "$REPO_ROOT/scripts"          "$REPO_ROOT/site" "$REPO_ROOT/wk" "$REPO_ROOT/hist"

cp -f "$PAY_ROOT/contract-templates/rexce-contract.yml"  "$REPO_ROOT/contract/rexce-contract.yml"
cp -f "$PAY_ROOT/contract-templates/rexce-contract.json" "$REPO_ROOT/contract/rexce-contract.json"

cp -f "$PAY_ROOT/tests-templates/validate_contract.py"   "$REPO_ROOT/tests/validate_contract.py"
chmod +x "$REPO_ROOT/tests/validate_contract.py" || true

for f in rexce-validation.yml rexce-release.yml rexce-daily.yml rexce-weekly.yml          rexce-auditor.yml rexce-contract-diff.yml rexce-snapshot-sign.yml rexce-autosync.yml; do
  cp -f "$PAY_ROOT/workflows-templates/$f" "$REPO_ROOT/.github/workflows/$f"
done

for s in gen-rollups.sh gen-sla.sh gen-heatmap.sh sign-snapshot.sh gen-repo-page.sh; do
  cp -f "$PAY_ROOT/scripts/$s" "$REPO_ROOT/scripts/$s"
  chmod +x "$REPO_ROOT/scripts/$s" || true
done

echo "[apply] bootstrap copied into: $(cd "$REPO_ROOT" && pwd)"
