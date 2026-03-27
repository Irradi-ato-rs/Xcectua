# Governance Propagation (Phase‑4)

## Purpose

Governance propagation ensures that:
- governance changes (GCPs)
- contract updates
- workflow updates
- evidence schema revisions

…can be safely proposed across many repositories with:
- consistent PR content
- consistent evidence
- proper ordering (waves)
- repeatable execution

Propagation is **not enforcement**.

---

# Key Tools

## `scripts/xce-propagate.sh`

Orchestrates:
- which repos are impacted
- in which order
- generates `xce-wave-plan.json`

Read‑only by default.

Usage:
./scripts/xce-propagate.sh --org my-org

Output:

xce-wave-plan.json

---

## `scripts/xce-wave-exec.sh`

Executes the wave plan.

Modes:

### Read‑only (default)
- prints planned actions
- executes diagnostics
- runs RER Doctor + gov-diff

### PR‑mode (`--pr-mode`)
Creates PRs but **never auto‑merges**.

Usage:

./scripts/xce-wave-exec.sh --pr-mode

---

## `scripts/xce-impact-analyzer.sh`

Given a GCP, determine:
- which repos reference affected governance paths
- which repos will need PRs

Usage:

./scripts/xce-impact-analyzer.sh --gcp GCP.md --org my-org

Outputs `xce-impact.json`.

---

# Guarantees

Propagation:
- is advisory
- is reversible
- is explicit
- is logged
- is evidence‑compatible

Propagation is not validation and not enforcement.

---

# Wave Planning

Each wave is:
- explicitly listed
- ordered
- traceable
- reproducible

No hidden decisions.
No silent actions.

---

# Evidence

Propagation integrates with Phase‑3 evidence, but:
- completeness only
- no correctness judgement
- no auto‑publishing