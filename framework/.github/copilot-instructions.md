# GitHub Copilot — Repository Instructions

> Copilot reads this file at the start of every chat session in this repo. Keep it short and load-bearing.

## What this repo uses

This repository is bootstrapped with the **SDLC Bootstrap Kit**: BMAD-METHOD v6 + GitHub Spec Kit + custom governance rules + missing role agents (Security, DevOps, Instruction Refactor, Instruction Loop).

## Before any action

1. **Read the constitution** at `.specify/memory/constitution.md`. It is the highest-priority source after explicit user direction.
2. **Identify the agent role** the user is invoking. Available agents live under `.bmad-core/agents/`. Default to the role that matches the artifact being touched.
3. **Apply the source-precedence rules** in section 10 of the constitution. On unresolvable conflict, stop and ask.

## Default behavior

- Honor the governance rules from `.bmad-additions/governance-rules.md` even when the user does not invoke a named agent.
- Smallest correct slice. No "while I'm here" expansion.
- Real code anchors required for any implementation work. Stop if missing.
- Stop and ask on contradictions between authoritative sources.
- For implementation work, prefer the Spec Kit slash command flow: `/specify` → `/plan` → `/tasks` → `/implement`.

## Model recommendations

- **Architecture, ADRs, security design, large refactors:** Claude Opus 4.6
- **Implementation, story execution, mechanical edits, backlog work:** Claude Sonnet 4.6 or GPT-5
- **UI-heavy with browser verification:** Gemini 3.5

You can switch models mid-task. The constitution and rules are model-agnostic.

## File ownership map (quick reference)

| Path | Owner |
|---|---|
| `.specify/memory/constitution.md` | User (you change it, not Copilot, unless explicitly asked) |
| `docs/VISION.md`, `docs/brief.md` | Analyst agent (Mary) |
| `docs/FUNCTIONAL_REQUIREMENTS.md`, `docs/epics/`, `docs/stories/` | PM (Preston), PO (Sally), SM (Simon) |
| `docs/NON_FUNCTIONAL_REQUIREMENTS.md`, `docs/architecture/` | Architect (Winston) |
| `docs/security/` | Security agent |
| `.github/workflows/`, `infra/`, `ops/`, `docs/ops/` | DevOps agent |
| `src/`, `app/`, `apps/`, `services/`, `packages/`, `lib/` | Developer (Devon) |
| Tests | QA agent (Quinn) |
| `.bmad-core/agents/*.md` | Instruction Refactor (via Instruction Loop only) |

## What NOT to do

- Do not write to a path owned by another agent — hand off instead.
- Do not invent architecture, components, or protocols outside the Architect agent.
- Do not bypass CI gates or modify branch protection without explicit user approval.
- Do not produce production code in `showcase/` or `demo/` unless the story is explicitly demo-scoped.
