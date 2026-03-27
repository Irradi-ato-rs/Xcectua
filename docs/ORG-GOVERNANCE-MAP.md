# Org‑Wide Governance Mapping (Phase‑4)

## Purpose

To generate an org‑scale understanding of:
- which repos are governed
- where governance artifacts exist
- which repos depend on rexce
- where RER Doctor runs
- how governance flows across repositories

Org‑mapping informs:
- propagation planning
- adoption
- drift detection
- evidence aggregation

---

# Tools

## `gov-scan-org.sh`
Detects:
- presence of rexce workflow
- presence of contract
- presence of rer-doctor
- default branch

Outputs: `gov-scan-org.json`

---

## `gov-state-org.sh`
Runs:
- RER Doctor (read‑only)
- gov-diff (read‑only)

Outputs: `governance-org.json`

---

## `gov-map.sh`
Produces a graph structure:

- nodes: repositories
- edges: governance relationships
  (contract references, doctor presence, common governance paths)

Outputs: `gov-map.json`

---

# Usage
./scripts/gov-scan-org.sh --org my-org
./scripts/gov-state-org.sh --org my-org
./scripts/gov-map.sh --org my-org

---

# Invariants

Org‑visibility tooling:

- never mutates repositories
- never validates correctness
- never enforces policy
- never touches branch protection
- never duplicates validator logic
- never opens PRs

Tools are strictly:
- observational
- advisory
- analytical

---

# Integration

Org‑mapping data feeds:

- dashboards
- propagation automation
- lifecycle planning
- governance adoption audits
- compliance reporting

Phase‑4 does not create new governance rules.  
It **maps**, **observes**, and **orchestrates**.