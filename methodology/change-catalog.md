# Change catalog

Standardized changes applied from a common baseline. Each change gets its own experiment directory under `experiments/` and a dedicated Git branch or commit.

## Baseline

Tag: `baseline-v1` (to be created when all three implementations reach parity for four deployment units).

## Changes

### 01 — Prod-only application size

**Intent:** Environment-scoped override.

Increase application instance size from `large` to `xlarge` (add mapping in shared module) **only** in `prod` units.

**Expected signal:** CA3 should be 2 (both prod regions); workspaces may need one tfvars edit per prod unit or a shared prod override.

---

### 02 — Region-specific alarm threshold

**Intent:** Region-scoped override.

Set CPU alarm threshold to `70` for `us-east-1` only (see [reference-scenario.md](reference-scenario.md)).

**Expected signal:** Affects `prod-us-east-1` only.

---

### 03 — Global application version

**Intent:** Cross-environment propagation.

Bump default `app_version` from `1.0.0` to `1.1.0` in all units.

**Expected signal:** High CA3 (all four units).

---

### 04 — Shared module tag

**Intent:** Shared module change amplification.

Add a mandatory `project = "thesis"` tag to all resources via shared module `tags` local.

**Expected signal:** Edit in `modules/` only; all implementations pick it up; plan affects all units.

---

### 05 — Add environment

**Intent:** Operational cost of scaling environments.

Add environment `test` with same shape as `dev` (`test-eu-central-1`).

**Expected signal:** AE metrics; new unit scaffolding per approach.

---

### 06 — Add region

**Intent:** Operational cost of scaling regions.

Add `eu-north-1` to `prod` (`prod-eu-north-1`).

**Expected signal:** AE metrics; prod-only regional expansion.

---

### 07 — Production HA exception

**Intent:** Environment exception pattern.

Enable database multi-AZ in `prod` only (already default in baseline prod—use as validation change: disable HA in `stage` while keeping `prod` unchanged, or add read replica only in prod).

**Concrete task:** Add optional read replica in `prod` units only.

---

### 08 — Add monitoring submodule

**Intent:** Structural change.

Add `dashboard_enabled` boolean to monitoring module; enable only in `stage` and `prod`.

**Expected signal:** Module interface change + per-env wiring differences.

## Execution order

Run changes in numerical order from the same baseline where possible. Reset to baseline between changes (branch per change, not cumulative).

## Per-change record template

```text
Change ID:
Approach:
Baseline ref:
Change ref:
CA1–CA5:
AE* (if applicable):
Notes:
```
