# Non-Functional Requirements

> Owned by the Architect. The constitution defines the baseline; this file defines the measurable thresholds and verification methods per quality attribute.

## Conventions

- IDs: `NFR-NNN`
- Each NFR has: scenario, measurable threshold, verification method, priority, FR/Vision trace
- Quality attributes follow ISO 25010

---

## NFR-001 — <Quality attribute>: <short title>

**Quality attribute:** <Performance | Security | Availability | Scalability | Usability | Maintainability | Portability | Compatibility | Reliability>
**Priority:** Must / Should / Could
**Constrains:** FR-XXX, FR-YYY (or "all")

### Scenario
Source, stimulus, environment, artifact, response, response measure (ATAM scenario format).

### Measurable threshold
e.g., "API p95 < 200ms under 100 RPS sustained load"

### Verification method
e.g., "Load test in `tests/load/` runs in CI on merge to main; fails build if breached over 3 consecutive runs"

### Architectural implications
Brief — what design constraints this NFR imposes. Full implications belong in `docs/architecture/`.

### Trace
- Vision: §<n>
- FRs: FR-XXX (which FRs it constrains)
- ADRs: ADR-XXXX (which ADRs were made to satisfy it)

---

## Traceability matrix

| NFR | Quality attribute | Threshold | Verification | FRs constrained | ADRs |
|---|---|---|---|---|---|
| NFR-001 | Performance | p95<200ms@100RPS | k6 load test in CI | FR-001, FR-002 | ADR-0003 |
