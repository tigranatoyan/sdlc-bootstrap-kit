# Governance Rules — Merge into every BMAD agent

These rules are merged into the `<rules>` section of every BMAD v6 agent file under `.bmad-core/agents/` during bootstrap. They harden BMAD's defaults with discipline patterns from the original Shawarma agent set.

**Do not** alter BMAD's persona, lifecycle, or handoff schema. Only add these to the `<rules>` block.

---

## Universal rules (apply to ALL agents)

- **READ** the project constitution at `.specify/memory/constitution.md` before any action.
- **READ** the canonical instruction file for your role before authoring or validating.
- **APPLY** the source-precedence rules from the constitution. If a conflict cannot be resolved by precedence, **STOP and ASK** the user which source supersedes before editing.
- **OWN ONLY** the artifacts in your declared ownership list. Do not author artifacts owned by another agent — route to that agent instead.
- **SMALLEST CORRECT SLICE:** produce the minimum change that satisfies the request. Do not expand scope to "while I'm here" improvements.
- **NO INVENTION:** do not invent architecture, components, protocols, or implementation details outside your role. Hand off instead.
- **TRACEABILITY:** every artifact must trace upward to a parent (Vision → FR → Epic → Story → Code).
- **STOP-AND-ASK** on any of: missing prerequisite, contradictory sources without precedence, ambiguous scope, missing code anchor (for Developer), unverified assumption (for QA).
- **READ-ONLY MODE** when the task is validation-only. Report findings; do not edit.

---

## Author-mode rules (PO, PM, Architect, SM, Dev, DevOps, Security)

- **REPORT FORMAT** for any edit:
  - Target artifacts (paths)
  - What changed (one-line per change)
  - Validation result or gap outcome
  - Required handoffs to other agents
- **TRACEABILITY UPDATE:** keep `docs/TRACEABILITY.md` (or BMAD's equivalent) current in the same change.

---

## Validation-mode rules (Review, QA)

- **READ-ONLY.** Never modify files.
- **PAIR** every criticism with a concrete suggestion.
- **PRIORITIZE** findings by severity: High, Medium, Low.
- **CITE** specific file paths and line ranges in findings.
- **CLEAN OR BLOCKED:** end with either "no material issues" or a clear list of what must change before re-review.

---

## Developer-specific rules

- **REAL CODE ANCHOR REQUIRED** before any edit. If the story does not name a concrete file or component to modify, stop and ask the SM agent.
- **FAILING TEST FIRST** when the change supports it. No new code without an executable check.
- **NO PRODUCTION CODE IN `showcase/` OR `demo/`** unless the story is explicitly demo-scoped.
- **NO ARCHITECTURE INVENTION.** If the work requires new components, services, or data stores, stop and hand off to Architect.

---

## Security-specific rules

- **OWASP ASVS L2 PASS** required on any story touching auth, sessions, data persistence, or external I/O.
- **DEPENDENCY CVE REVIEW** on any package add/upgrade.
- **THREAT MODEL DELTA** for any new external-facing surface.
- **GATE THE PR** with the security check status — do not let stories merge with unresolved High findings.

---

## DevOps-specific rules

- **NEVER TOUCH** existing CI workflows in brownfield mode without explicit approval.
- **ADDITIVE ONLY** by default. New workflows go alongside existing ones, not replacing them.
- **FITNESS FUNCTIONS** must be machine-checkable and fail loudly in CI, not be advisory.

---

## Instruction Loop / Refactor specific rules

- **ONLY EDIT** `.bmad-core/agents/*.md` and `.specify/memory/*.md`.
- **PRESERVE** persona, lifecycle, and handoff schemas in BMAD agents — only edit the `<rules>` section.
- **3-PASS LIMIT** for review → refactor → review cycles. Stop if findings repeat without progress.
- **STOP AND ASK** if review findings contradict the constitution.
