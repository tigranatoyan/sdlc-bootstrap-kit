# Functional Requirements

> This is the authoritative functional baseline. When older artifacts conflict, this file wins (per constitution §10).

## Conventions

- IDs: `FR-NNN` (zero-padded, never reused, never renumbered)
- Priority: MoSCoW (Must / Should / Could / Won't)
- Status: Draft / Approved / Deprecated
- Trace upward: every FR cites the Vision section it serves
- Trace downward: epics, stories, and tests cite the FRs they implement

---

## FR-001 — <short imperative title>

**Priority:** Must
**Status:** Draft
**Vision link:** §<n>

### Description
One paragraph. What capability does this provide, to whom, in what context?

### Acceptance criteria
- Given `<precondition>`, when `<action>`, then `<observable outcome>`
- ...

### Out of scope
Bullets clarifying what this FR does NOT cover, to prevent scope creep into adjacent FRs.

### Dependencies
- FR-XXX (must ship first / together with)
- External: <e.g., third-party API, regulatory approval>

### Notes
Any context the SM will need when sharding into stories.

---

## FR-002 — <next>

(repeat structure)

---

## Traceability matrix

| FR | Vision section | Epic | Stories | NFRs that constrain it |
|---|---|---|---|---|
| FR-001 | §3, §6 | EPIC-01 | S-001, S-002 | NFR-002, NFR-005 |
