#!/usr/bin/env bash
set -euo pipefail

#
# xce-impact-analyzer.sh — Determine cross‑repo impact of a GCP
#
# Responsibilities:
#   ✅ Read GCP content
#   ✅ Infer which files / governance dimensions change
#   ✅ Perform advisory cross‑repo impact analysis
#   ✅ Output machine‑readable JSON
#   ❌ Never enforce
#   ❌ Never validate correctness
#

export NO_COLOR=1

GCP="GCP.md"
ORG=""
OUTPUT="xce-impact.json"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --gcp)
      GCP="$2"; shift 2;;
    --org)
      ORG="$2"; shift 2;;
    --out)
      OUTPUT="$2"; shift 2;;
    *)
      echo "Unknown argument: $1" >&2; exit 1;;
  esac
done

if [[ -z "$ORG" ]]; then
  echo "ERROR: --org <org> required" >&2
  exit 1
fi

if [[ ! -f "$GCP" ]]; then
  echo "ERROR: GCP file not found: $GCP" >&2
  exit 1
fi

# Extract governance files referenced in GCP (advisory only)
changes=$(grep -Eo 'contract/[^ )]+' "$GCP" | sort -u | jq -R . | jq -s .)

echo "Scanning org $ORG for impacted repos..." >&2
repos=$(gh repo list "$ORG" --json nameWithOwner --limit 300 | jq -r '.[].nameWithOwner')

impact_map=()

for repo in $repos; do
  echo "Analyzing $repo..." >&2

  # simple heuristic: does repo contain referenced paths?
  impacted=false
  for file in $(printf "%s" "$changes" | jq -r '.[]'); do
    if gh api "repos/$repo/contents/$file" >/dev/null 2>&1; then
      impacted=true
      break
    fi
  done

  if [[ "$impacted" == true ]]; then
    impact_map+=("$repo")
  fi
done

jq -n \
  --arg gcp "$GCP" \
  --arg org "$ORG" \
  --argjson changes "$changes" \
  --argjson impacted "$(printf '%s\n' "${impact_map[@]:-}" | jq -R . | jq -s .)" \
  '
  {
    version: "1.0.0",
    gcp_file: $gcp,
    org: $org,
    referenced_governance_paths: $changes,
    impacted_repositories: $impacted,
    generated_at: (now | todate)
  }
  ' > "$OUTPUT"

echo "Impact analysis written to $OUTPUT" >&2