#!/usr/bin/env bash
set -euo pipefail
export NO_COLOR=1

ORG=""
OUTPUT="governance-org.json"

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

echo "Fetching repositories for $ORG..." >&2
repos=$(gh repo list "$ORG" --json nameWithOwner,defaultBranchRef --limit 500)

states=()

for row in $(echo "$repos" | jq -c '.[]'); do
  repo=$(echo "$row" | jq -r '.nameWithOwner')
  branch=$(echo "$row" | jq -r '.defaultBranchRef.name')

  echo "Collecting governance state for $repo..." >&2

  rer_json=$(./scripts/rer-doctor.sh --repo "$repo" --json 2>/dev/null || echo '{}')
  diff_json=$(./scripts/gov-diff.sh "$repo@$branch" "$repo@$branch" --json 2>/dev/null || echo '{}')

  states+=("$(jq -n \
    --arg repo "$repo" \
    --arg branch "$branch" \
    --argjson rer "$rer_json" \
    --argjson diff "$diff_json" \
    '{
      repo: $repo,
      branch: $branch,
      rer_doctor: $rer,
      gov_diff: $diff
    }')")
done

jq -n \
  --arg org "$ORG" \
  --arg generated "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
  --argjson states "$(printf '%s\n' "${states[@]}" | jq -s '.')" \
  '
  {
    version: "1.0.0",
    org: $org,
    generated_at: $generated,
    repositories: $states
  }
  ' > "$OUTPUT"

echo "Org governance state written to $OUTPUT" >&2