#!/usr/bin/env bash
set -euo pipefail

#
# xce-wave-exec.sh — Execute Phase‑4 Rollout Waves
#
# Responsibilities:
#   ✅ Read wave plans
#   ✅ Process repos in planned waves
#   ✅ Run RER Doctor and gov-diff (read‑only)
#   ✅ Optional PR creation with --pr-mode
#   ❌ Never auto-merge
#   ❌ Never enforce anything
#

export NO_COLOR=1

PLAN="xce-wave-plan.json"
PR_MODE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --plan)
      PLAN="$2"; shift 2;;
    --pr-mode)
      PR_MODE=true; shift;;
    *)
      echo "Unknown argument: $1" >&2; exit 1;;
  esac
done

if [[ ! -f "$PLAN" ]]; then
  echo "ERROR: wave plan not found: $PLAN" >&2
  exit 1
fi

waves=$(jq -c '.waves[]' "$PLAN")

for wave in $waves; do
  wave_id=$(printf "%s" "$wave" | jq -r '.wave_id')
  echo "=== Executing Wave $wave_id ===" >&2

  repos=$(printf "%s" "$wave" | jq -r '.repos[]')

  for repo in $repos; do
    echo "Processing $repo..." >&2

    # read‑only state fetch
    rer_json=$(./scripts/rer-doctor.sh --repo "$repo" --json 2>/dev/null || echo '{}')
    diff_json=$(./scripts/gov-diff.sh "$repo@default" "$repo@default" --json 2>/dev/null || echo '{}')

    # if PR mode enabled → propose a governance update PR
    if [[ "$PR_MODE" == true ]]; then
      echo "Creating PR for $repo (manual review required)..." >&2
      # NO auto‑merge, NO direct pushes
      gh pr create \
        --repo "$repo" \
        --title "Governance Update - Wave $wave_id" \
        --body "Automated governance rollout proposal under Phase‑4. Please review." \
        --base "main" \
        --head "governance/update-wave-$wave_id"
    fi
  done
done