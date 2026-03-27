#!/usr/bin/env bash
set -euo pipefail
export NO_COLOR=1

ORG=""
OUTPUT="gov-scan-org.json"

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

echo "Enumerating repositories for org: $ORG..." >&2

repos=$(gh repo list "$ORG" --json nameWithOwner,defaultBranchRef --limit 500)

results=()

for row in $(echo "$repos" | jq -c '.[]'); do
  repo=$(echo "$row" | jq -r '.nameWithOwner')
  branch=$(echo "$row" | jq -r '.defaultBranchRef.name')

  echo "Scanning $repo..." >&2

  # Read-only governance presence checks
  has_rexce=false
  has_doctor=false
  has_contract=false

  if gh api repos/"$repo"/contents/.github/workflows/rexce-validation.yml >/dev/null 2>&1; then
    has_rexce=true
  fi

  if gh api repos/"$repo"/contents/scripts/rer-doctor.sh >/dev/null 2>&1; then
    has_doctor=true
  fi

  if gh api repos/"$repo"/contents/contract/rexce-contract.yml >/dev/null 2>&1; then
    has_contract=true
  fi

  results+=("$(jq -n \
    --arg repo "$repo" \
    --arg branch "$branch" \
    --argjson rexce "$has_rexce" \
    --argjson doctor "$has_doctor" \
    --argjson contract "$has_contract" \
    '{repo:$repo, branch:$branch, governance:{rexce:$rexce, rer_doctor:$doctor, contract:$contract}}')")
done

printf "%s\n" "${results[@]}" | jq -s '.' > "$OUTPUT"

echo "Scan written to $OUTPUT" >&2