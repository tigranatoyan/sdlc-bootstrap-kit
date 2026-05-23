# Project Constitution

> This file is load-bearing. Every BMAD agent, every Spec Kit command, and every Copilot session reads this first.
> Keep it concise, opinionated, and current. If a section becomes wrong, fix it the day you notice.

---

## Metadata

```yaml
project_name: <fill-in>
version: 1.0.0
bootstrap_kit_version: <set by BOOTSTRAP.md>
created: <YYYY-MM-DD>
last_reviewed: <YYYY-MM-DD>
```

---

## 1. Mission

One paragraph. What does this project exist to do? Who suffers if it doesn't exist?

> *Example: Shawarma is a fast-casual restaurant POS that lets a single operator manage orders, inventory, and reporting on a tablet — so independent shop owners stop paying $300/month for enterprise POS they only use 10% of.*

---

## 2. Target users

Primary, secondary, tertiary. For each, name the user, their context, and their core job-to-be-done.

---

## 3. Non-negotiable stack

These are bound. Changing one is an ADR-level decision.

- **Language(s):** <fill-in>
- **Frontend framework:** <fill-in>
- **Backend framework:** <fill-in>
- **Database(s):** <fill-in>
- **Auth:** <fill-in>
- **Hosting / deploy target:** <fill-in>
- **Package manager:** <fill-in>
- **Build / bundler:** <fill-in>
- **Test framework(s):** <fill-in>

---

## 4. Security baseline

Default to OWASP ASVS Level 2 unless declared otherwise.

- **AppSec standard:** OWASP ASVS L2
- **Dependency scanning:** Snyk + Dependabot, weekly
- **Secret scanning:** GitHub native, blocking on push
- **Threat model:** STRIDE pass per new external-facing feature; lives at `docs/security/threat-model.md`
- **PII / data classification:** <fill-in>
- **Compliance regimes in scope:** <e.g., GDPR, SOC2, none>

---

## 5. Performance budgets

Measurable thresholds. Verified in CI.

- **API p95 latency:** <e.g., 200ms>
- **API p99 latency:** <e.g., 500ms>
- **Web Vitals — LCP / CLS / INP:** <fill-in>
- **Cold-start budget (if serverless):** <fill-in>
- **Bundle size cap:** <fill-in>

---

## 6. Accessibility floor

- **Standard:** WCAG 2.2 AA
- **Verified by:** axe-core in CI + manual screen-reader pass per release

---

## 7. Testing requirements

- **Coverage floor — line:** 80%
- **Coverage floor — critical paths:** 100%
- **Required test types:** unit, integration, contract, e2e
- **Test pyramid policy:** integration > unit > e2e (favor integration over heavy unit mocking)
- **Mocking policy:** <fill-in — see governance rules>

---

## 8. Branching, PR, and review policy

- **Default branch:** `main`
- **Branch naming:** `feat/`, `fix/`, `chore/`, `docs/` + story-id slug
- **PR title format:** `<type>(<area>): <story-id> <story-name>`
- **Required PR checks:** lint, type, test, coverage, fitness, security, CodeRabbit, 1 human approval
- **Squash vs merge:** squash
- **Conventional commits:** required

---

## 9. Observability

- **Logging:** structured JSON, level + correlation id required
- **Tracing:** OpenTelemetry, sampling at <X>%
- **Metrics:** RED for services, USE for resources
- **Dashboards live at:** <fill-in>
- **On-call runbook lives at:** `docs/ops/runbooks/`

---

## 10. Source-precedence rules

When artifacts conflict, this order resolves the conflict unless an ADR overrides it for a specific decision:

1. Explicit user direction in the current conversation
2. This `constitution.md`
3. `docs/NON_FUNCTIONAL_REQUIREMENTS.md`
4. `docs/FUNCTIONAL_REQUIREMENTS.md` (latest)
5. `docs/architecture/decisions/*.md` (latest ADR for the affected area)
6. `docs/architecture/*.md`
7. `docs/stories/*.md`
8. Existing code

Agents must stop and ask if a conflict is not resolvable by this order.

---

## 11. Definition of "Ready for Development"

A story may enter implementation only when all are true:
- Linked to a parent epic, FR, and Vision goal
- Acceptance criteria expressed as testable Given/When/Then
- Implementation brief includes file/component anchors
- NFR impact assessed (perf, security, accessibility)
- Test plan exists
- No open architecture questions

---

## 12. Definition of "Done"

A PR may merge only when all are true:
- All CI checks green (lint, type, test, coverage, fitness, security)
- Coverage delta non-negative on the touched files
- CodeRabbit + human review approved
- Docs updated (story, FR/NFR if scope changed, ADR if architecture changed)
- Observability hooks present for any new code path

---

## 13. Cadence

- **Story cycle target:** <e.g., 2 days median>
- **Constitution review:** monthly
- **Retrospective:** weekly (Instruction Loop agent + manual)
- **Dependency upgrade window:** weekly Monday

---

## 14. What this constitution explicitly does NOT cover

List things you've decided are out of scope, so agents don't try to fill the gap by inventing.

> *Example: This constitution does not cover internationalization — Shawarma is English-only v1. Re-open in v2.*

---

## 15. Sign-off

Updated by: <name>
Approved on: <date>
