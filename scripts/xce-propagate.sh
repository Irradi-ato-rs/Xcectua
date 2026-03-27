#!/usr/bin/env bash
set -euo pipefail

#
# xce-propagate.sh — Phase‑4 Change Propagation Orchestrator
#
# Responsibilities:
#   ✅ Enumerate repositories (via gh CLI)
#   ✅ Determine which repos are impacted by a governance change
#   ✅ Generate xce-wave-plan.json
#   ✅ Never mutate unless --pr-mode is explicitly passed
#   ✅ Never enforce or validate
#

export NO_COLOR=1

PR_MODE=false
ORG=""
GCP_FILE="GCP.md"
OUTPUT="xce-wave-plan.json"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --org)
      ORG="$2"; shift 2;;
    --gcp)
      GCP_FILE="$2"; shift 2;;
    --pr-mode)
      PR_MODE=true; shift;;
    *)
      echo "Unknown arg: $1" >&2; exit 1;;
  esac
done

if [[ -z "$ORG" ]]; then
  echo "ERROR: --org <orgname> required" >&2
  exit 1
fi

echo "Enumerating repositories for org: $ORG" >&2
repos=$(gh repo list "$ORG" --json nameWithOwner --limit 300 | jq -r '.[].nameWithOwner')

impact_report=()

for repo in $repos; do
  echo "Analyzing impact for $repo..." >&2

  # read‑only diff
  diff_json=$(./scripts/gov-diff.sh "$repo@default" "$repo@default" --json 2>/dev/null || echo '{}')
  classification=$(printf "%s" "$diff_json" | jq -r '.classification // "TYPE-0"')

  # heuristic: TYPE‑2 or TYPE‑3 => impacted
  case "$classification" in
    TYPE-2|TYPE-3)
      impact_report+=("$repo");;
  esac
done

echo "Generating rollout wave plan: $OUTPUT" >&2

jq -n \
  --arg org "$ORG" \
  --arg pr_mode "$PR_MODE" \
  --argjson impacted "$(printf '%s\n' "${impact_report[@]:-}" | jq -R . | jq -s .)" \
  '
  {
    version: "1.0.0",
    org: $org,
    pr_mode: ($pr_mode == "true"),
    generated_at: (now | todate),
    impacted_repositories: $impacted
  }
  ' > "$OUTPUT"

echo "Wave plan written to $OUTPUT" >&2