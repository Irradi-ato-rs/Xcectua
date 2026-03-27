# Governance Lifecycle (Phase‑4)

## Overview

The governance lifecycle now spans:

1. **Proposal** — GCP creation
2. **Diff** — gov-diff classification (TYPE‑0…TYPE‑3)
3. **Evidence** — local completeness bundle
4. **Propagation** — multi‑repo wave generation
5. **Review** — human review only
6. **Enforcement** — Phase‑2 (rexce validation) on PR merge

Phase‑4 introduces automation for **steps 4 and 5 only**.

---

# Lifecycle Stages

## 1. GCP Creation (human)
Defines intent, motivation, scope.

## 2. Diff Visibility (automated, read‑only)
`gov-diff.sh` provides classification and structure.

## 3. Evidence Preparation (automated + human)
`xce-bundle-evidence.sh` produces a deterministic bundle.

## 4. Propagation Planning (automated)
`xce-propagate.sh` determines impacted repositories.

## 5. Wave Execution (semi‑automated)
`xce-wave-exec.sh --pr-mode` creates PRs.

## 6. Human Review (mandatory)
Review happens per repository.

## 7. Enforcement (automatic, Phase‑2)
Only rexce validates.
Only GitHub blocks merges.

---

# Lifecycle Guarantees

- Human remains in control
- No auto‑merge
- No background changes
- No unrequested propagation
- No cross‑repo enforcement
- No local bypasses

---

# PR‑Mode Boundary

Propagation tools only modify repos when explicitly invoked:
--pr-mode

Without this flag:
- ZERO mutations occur
- scripts operate as visibility‑only

This is a governance invariant.