# Phase‑4 — Automation Layer (Non‑Enforcing, Org‑Wide)

## Purpose

Phase‑4 expands the governance system from single‑repository evolution (Phase‑3)
into multi‑repository automation, visibility, and orchestration.

Phase‑4 **does not**:
- introduce new enforcement
- change validation semantics
- modify Phase‑2 invariants
- introduce validator logic outside rexce
- bypass branch protection
- auto‑fix or auto‑merge anything

Phase‑4 **does**:
- automate discovery
- automate visibility
- automate change propagation preparation
- automate org‑wide evidence gathering
- generate rollout plans
- enable safe PR batching (explicit user‑intent only)

---

# Phase‑4 Objectives

1. Org‑wide governance visibility
2. Org‑wide governance state snapshots
3. Governance dependency mapping
4. Multi‑repo change propagation (read‑only by default)
5. Rollout wave planning
6. Optional PR‑mode for generating update proposals
7. Evidence batching at org‑scale

Phase‑4 builds the “governance mesh”—not enforcement.

---

# Guarantees & Boundaries

Phase‑4 is **automation around governance**, not governance itself.

All scripts MUST:
- run in **read‑only mode by default**
- never mutate repositories unless explicit `--pr-mode` is passed
- never validate governance logic
- never enforce constraints
- never modify branch protections
- never alter required checks
- never behave as a validator

Only rexce validates.
Only GitHub enforces.
Phase‑4 observes and automates around these.

---

# Tooling Introduced in Phase‑4

All scripts live under:
scripts/

## Org‑wide visibility

- `gov-scan-org.sh`
- `gov-state-org.sh`
- `gov-map.sh`

## Propagation & lifecycle

- `xce-propagate.sh`
- `xce-wave-exec.sh`
- `xce-impact-analyzer.sh`

## Data Shapes

All Phase‑4 tools emit deterministic, machine‑readable, JSON‑stable output for:
- dashboards
- audit logs
- propagation planning
- evidence bundling

---

# Relationship to Previous Phases

| Phase | Purpose | Status | Notes |
|------|----------|--------|-------|
| Phase‑2 | Enforcement, validation, determinism | ✅ frozen | Cannot change |
| Phase‑3 | Evolution, evidence, diff visibility | ✅ stable | Single‑repo |
| **Phase‑4** | Org‑automation, propagation, mapping | ✅ active | Non‑enforcing |

---

# Governance Safety Checklist

Phase‑4 preserves:

✅ single required check (`rexce/validate`)  
✅ no admin bypass  
✅ no duplicate validators  
✅ no enforcement drift  
✅ read‑only defaults  
✅ explicit PR‑only mutation  

Phase‑4 is safe to adopt and safe to extend.