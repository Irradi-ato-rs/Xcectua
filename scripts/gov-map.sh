#!/usr/bin/env bash
set -euo pipefail
export NO_COLOR=1

ORG=""
OUTPUT="gov-map.json"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --org) ORG="$2"; shift 2;;
    --out) OUTPUT="$2"; shift 2;;
    *) echo "Unknown argument: $1" >&2; exit 1;;
  esac
done

if [[ -z "$ORG" ]]; then
  echo "ERROR: --org <org> required" >&2
  exit 1
fi

echo "Building governance dependency map for $ORG..." >&2
repos=$(gh repo list "$ORG" --json nameWithOwner --limit 500 | jq -r '.[].nameWithOwner')

edges=()
nodes=()

for repo in $repos; do
  echo "Inspecting $repo..." >&2

  nodes+=("$repo")

  # Check dependencies implied by contract references
  contract=$(gh api "repos/$repo/contents/contract/rexce-contract.yml" 2>/dev/null || true)
  if [[ -n "$contract" ]]; then
    edges+=("$(jq -n --arg from "$repo" --arg to "rexce" '{from:$from, to:$to}')")
  fi

  # Check dependency on rer-doctor
  if gh api "repos/$repo/contents/scripts/rer-doctor.sh" >/dev/null 2>&1; then
    edges+=("$(jq -n --arg from "$repo" --arg to "rer-doctor" '{from:$from, to:$to}')")
  fi
done

jq -n \
  --arg org "$ORG" \
  --arg generated "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
  --argjson nodes "$(printf '%s\n' "${nodes[@]}" | jq -R . | jq -s '.')" \
  --argjson edges "$(printf '%s\n' "${edges[@]}" | jq -s '.')" \
  '
  {
    version: "1.0.0",
    org: $org,
    generated_at: $generated,
    nodes: $nodes,
    edges: $edges
  }
  ' > "$OUTPUT"

echo "Governance dependency map written to $OUTPUT" >&2