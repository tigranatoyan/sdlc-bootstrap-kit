# BOOTSTRAP.md — Master Prompt for Copilot Agent Mode

> **You are GitHub Copilot in VS Code Agent Mode.** This file is your end-to-end instruction set for installing the SDLC framework into this repository. Execute the phases below in order. **Stop and ask the user** at every gate marked `🛑 GATE`. **Approve nothing destructive without explicit user confirmation.**

> **BMAD v6.6 layout note:** BMAD v6.6 installs at `_bmad/` (core) + `skills/` (skill registry) + `.agents/skills/bmad-*/` (per-persona skill packs) + `bmm/` + `config.toml`. Personas (Mary/Preston/Winston/Sally/Simon/Devon/Quinn) are reached via the skill mechanism, NOT as standalone Copilot `@`-mentionable agents. Copilot-invocable agents live in `.github/agents/*.agent.md`. This BOOTSTRAP respects that layout.

---

## Phase 0 — Source-of-Truth Resolution (always first)

Determine whether kit files are already in this repo or need to be fetched.

```
RUN: check if `framework/.github/agents/sdlc-engine.agent.md` exists in this repo
RUN: check if `.bmad-additions/governance-rules.md` exists
```

If kit files are **present locally**, proceed to Phase A.

If kit files are **absent**, switch to URL-FETCH MODE:

1. Ask user: "I do not see kit files locally. Fetch from SDLC Bootstrap Kit? Default URL: `https://github.com/tigranatoyan/sdlc-bootstrap-kit` (branch: `main`). Confirm URL or override."
2. With approved URL `<KIT_URL>` and branch `<KIT_BRANCH>`:
   ```bash
   git clone --depth 1 --branch <KIT_BRANCH> <KIT_URL> /tmp/sdlc-kit
   ```
3. Copy framework files into current repo:
   - **Greenfield (current dir clean):** `cp -r /tmp/sdlc-kit/framework/. .`
   - **Brownfield (current dir has files):** stop and ask per-conflict approval. Use kit's `framework/` as source; for each file, if target exists show diff and ask; if target missing, copy.
4. Copy `BOOTSTRAP.md` from `/tmp/sdlc-kit/BOOTSTRAP.md` to current dir, overwrite only with approval if differs.
5. Record kit version from Phase Z; will stamp into constitution at Phase C.8/D.6.
6. Proceed to Phase A.

🛑 **GATE 0:** URL and version confirmed before any file copy.

---

## Phase A — Mode Detection (always)

```
RUN: list contents of current directory
RUN: check git status
```

Decision tree:

- **GREENFIELD MODE** if all of:
  - No files under `src/`, `app/`, `apps/`, `services/`, `packages/`, `lib/`
  - No `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `pom.xml`, `Gemfile`
  - No `docs/` content beyond `docs/templates/`
  - No `.github/workflows/` content
- **BROWNFIELD MODE** otherwise
- **UPGRADE MODE** if `.specify/memory/constitution.md` exists with `bootstrap_kit_version:` line

State detected mode explicitly:

> "Detected mode: `<MODE>`. I will follow the `<MODE>` path. Confirm to proceed, or override by saying 'use <other> mode'."

🛑 **GATE 1: Mode confirmation.**

---

## Phase B — Common Prerequisites

Check installed, offer to install missing:

- `node` v20+ (`node --version`)
- `npm` (`npm --version`)
- `pipx` or `uv` (preferred over raw `pip` on Windows; `pipx --version` or `uv --version`)
- `gh` (GitHub CLI) (`gh --version`)
- `claude` (Claude Code CLI) (`claude --version`)

If missing, present install commands and wait for approval.

🛑 **GATE 2: Prerequisites confirmed.**

---

## Phase C — GREENFIELD PATH

Skip if not greenfield.

### C.1 Install BMAD-METHOD v6 (pinned)

```bash
npx --yes bmad-method@${BMAD_VERSION} install --preset greenfield-fullstack --ide vscode --non-interactive
```

After install, list what was added. Expected v6.6 structure (verify):
- `_bmad/` — core
- `skills/` — skill registry
- `.agents/skills/bmad-*/` — per-persona skill packs
- `bmm/` — BMAD method manager
- `config.toml` — BMAD config

### C.2 Install GitHub Spec Kit (pinned)

```bash
# Use uv on Windows (pip can fail with WinError 5). Use pipx elsewhere.
uv tool install "specify-cli==${SPECKIT_VERSION}" || pipx install --force "specify-cli==${SPECKIT_VERSION}"
specify init --here --ai copilot
```

### C.3 Verify kit framework files in place

User has already copied `framework/` contents to repo root (via Phase 0 fetch or manual). Verify:

- `.github/agents/sdlc-engine.agent.md` exists
- `.github/agents/security.agent.md` exists
- `.github/agents/devops.agent.md` exists
- `.github/agents/instruction-refactor.agent.md` exists
- `.github/agents/instruction-loop.agent.md` exists
- `.specify/memory/constitution.template.md` exists
- `.bmad-additions/governance-rules.md` exists
- `.github/copilot-instructions.md` exists
- `docs/templates/` has four template files

If any missing, stop and tell the user.

### C.4 Merge kit governance rules into BMAD persona skill prompts

Read `.bmad-additions/governance-rules.md`. For each BMAD persona skill pack under `.agents/skills/bmad-*/`, identify the persona's prompt file (typically `prompt.md` or `persona.md` inside the skill directory). Append the relevant governance rules under a `## Governance Rules (from SDLC Bootstrap Kit)` section. Do NOT alter the persona's identity or workflow — only add rules to the `<rules>` block if present, or to a `## Governance` section if not.

Show user the diff per persona before applying. After approval, apply.

### C.5 Confirm Copilot agent registration

The 5 kit agents are already in `.github/agents/*.agent.md` from the framework copy. Copilot picks them up automatically on Chat panel reload. Verify:

```powershell
Get-ChildItem .github/agents/ -Name -Filter "*.agent.md"
```

Expected output includes: `sdlc-engine.agent.md`, `security.agent.md`, `devops.agent.md`, `instruction-refactor.agent.md`, `instruction-loop.agent.md`.

Instruct user: "Close and reopen Copilot Chat panel (or Ctrl+Shift+P → 'Developer: Reload Window') to register the new agents. Type `@sdlc` in chat input to confirm `@sdlc-engine` appears."

### C.6 (Optional) Install understand-anything plugin via Claude Code

```bash
claude plugin marketplace add Lum1104/Understand-Anything
claude plugin install understand-anything
```

Add `understand-anything-output/`, `.understandignore`, `intermediate/`, `tmp/` to `.gitignore`.

**Windows users:** if the scanner hangs (known issue), skip this step. Add a backlog item to `docs/ops/known-issues/understand-anything-windows.md` and continue.

### C.7 First commit (in atomic chunks)

Stage and commit in this order, one commit per chunk:

1. `chore: install BMAD-METHOD v${BMAD_VERSION}` — `_bmad/`, `skills/`, `.agents/skills/bmad-*/`, `bmm/`, `config.toml`, related .gitignore additions
2. `chore: install Spec Kit v${SPECKIT_VERSION}` — `.specify/` scaffolding except constitution.md, slash command files
3. `feat: install SDLC kit framework files` — `.github/agents/*.agent.md` (5 kit agents), `.github/copilot-instructions.md`, `.bmad-additions/governance-rules.md`, `docs/templates/*`
4. `feat: merge SDLC governance into BMAD persona skills` — modifications to `.agents/skills/bmad-*/`
5. (optional) `chore: install understand-anything plugin` — gitignore additions if you ran C.6

Do NOT push without user approval.

🛑 **GATE 3: Framework installed and committed.**

### C.8 Constitution interview

Open `.specify/memory/constitution.template.md`. Interview user one section at a time. Do not write any section without their answer. Cover every template section. After each section, draft inline and wait for "ok".

When complete, write `.specify/memory/constitution.md`, set `bootstrap_kit_version:` to `KIT_VERSION` from Phase Z, commit as `docs: project constitution v1.0.0`.

🛑 **GATE 4: Constitution complete.**

### C.9 Hand off to BMAD lifecycle via SDLC Engine

Tell user:

> "Framework installed and constitution set. To generate artifacts from scratch, switch model to **Claude Opus 4.6** and prompt:
> `@sdlc-engine pipeline mode. initiate from requirements review. stop at ready-for-development gate.`
> SDLC Engine will route through BMAD personas (Mary → Preston → Winston → Sally → Simon) and stop before any code is written for your approval."

End BOOTSTRAP execution.

---

## Phase D — BROWNFIELD PATH

Skip if not brownfield.

### D.1 Reconnaissance (read-only)

Produce a short inventory report:
- Language(s) and frameworks (from package manifests)
- Existing CI workflows under `.github/workflows/`
- Existing docs under `docs/` and root `*.md`
- Test framework(s) detected
- Lint/formatter configs detected
- Existing `.github/copilot-instructions.md`, `.cursorrules`, `CLAUDE.md`, or `.github/agents/*.agent.md`

Show report. **No file changes yet.**

🛑 **GATE D1: Reconnaissance reviewed.**

### D.2 Install BMAD-METHOD v6 in brownfield mode (pinned)

```bash
npx --yes bmad-method@${BMAD_VERSION} install --preset brownfield --ide vscode --non-interactive
```

Brownfield preset is more conservative — does not assume project structure.

### D.3 Install Spec Kit (pinned, Windows-safe)

```bash
uv tool install "specify-cli==${SPECKIT_VERSION}" || pipx install --force "specify-cli==${SPECKIT_VERSION}"
specify init --here --ai copilot
```

### D.4 Merge kit framework files non-destructively

For each file in `framework/`:
- If target path does NOT exist → copy
- If target path EXISTS → produce three-way merge proposal, ask user before writing

Specifically:
- `.github/agents/*.agent.md` — if any of the 5 kit agents collide with existing agents, ask user whether to overwrite, rename, or skip
- `.github/copilot-instructions.md` — if exists, append kit content under `## SDLC Framework Rules` section; else create
- `docs/templates/*` — create only if missing

### D.5 (Optional) Run understand-anything on existing code

```bash
claude plugin marketplace add Lum1104/Understand-Anything
claude plugin install understand-anything
claude /understand
```

**Windows users:** skip if scanner hangs. Park in `docs/ops/known-issues/`.

### D.6 Reverse-engineer Vision and Constitution

Activate BMAD Analyst persona (Mary) via skill mechanism. Interview user, primed with what was found in reconnaissance:

> "I've read your existing README, docs, and code. Based on that, I drafted candidate Vision and Constitution sections. Walk through each — confirm, correct, or expand."

For each candidate section, present draft and source files/lines you derived it from. Get approval before writing.

Write to:
- `docs/VISION.md` (if not already present)
- `.specify/memory/constitution.md` with `bootstrap_kit_version:` set to `KIT_VERSION`

🛑 **GATE D2: Vision and Constitution confirmed.**

### D.7 Reverse-engineer FRs, NFRs, Architecture

Activate BMAD PM (Preston) for FRs, then Architect (Winston) for NFRs + architecture, via skill mechanism. Both should read the existing code (and understand-anything graph if available) and produce *as-built* documents reflecting what the code actually does — flagging gaps or contradictions.

Write to:
- `docs/FUNCTIONAL_REQUIREMENTS.md`
- `docs/NON_FUNCTIONAL_REQUIREMENTS.md`
- `docs/architecture/*.md` (C4 levels, runtime view, deployment view, data model)
- `docs/architecture/decisions/ADR-XXXX-*.md` (one per non-trivial decision detected)

Each artifact must include an `## As-Built vs Intended` section flagging where code diverges.

🛑 **GATE D3: As-built documents reviewed.**

### D.8 Add missing CI/CD gates non-destructively

Invoke `@devops`. Read existing `.github/workflows/`. Add only what's missing:
- `architecture-fitness.yml` (if absent)
- `security.yml` (if no Snyk/CodeQL workflow exists)

Do NOT touch existing `ci.yml`, `release.yml`, etc.

### D.9 Commit in atomic chunks

Same chunked commit pattern as C.7:

1. `chore: install BMAD-METHOD v${BMAD_VERSION}`
2. `chore: install Spec Kit v${SPECKIT_VERSION}`
3. `feat: install SDLC kit framework files`
4. `feat: merge SDLC governance into BMAD persona skills`
5. `docs: reverse-engineered VISION and constitution v1.0`
6. `docs: reverse-engineered FRs, NFRs, architecture v1.0`
7. `ci: SDLC quality gates`
8. (optional) `chore: install understand-anything plugin`

🛑 **GATE D4: Brownfield bootstrap complete.**

### D.10 Hand off to daily loop

Tell user:

> "Framework layered onto existing code. As-built docs are your starting baseline. Reload Copilot Chat panel to register the kit agents. To improve the as-built docs or ship the next feature:
> `@sdlc-engine analyze FRs for completeness`
> or
> `@sdlc-engine pipeline mode. resume from ready-for-development gate. implement story S-XXX.`"

End BOOTSTRAP execution.

---

## Phase E — UPGRADE PATH

Skip if not upgrade.

### E.1 Read current version

Read `.specify/memory/constitution.md` → `bootstrap_kit_version:` value. Call this `OLD_VERSION`. Current kit's version is `KIT_VERSION` in Phase Z.

### E.2 Diff framework folder

For each file in kit's `framework/`, compare with target file in project. Produce diff report grouped by:
- New files (additive — safe)
- Changed templates (need merge)
- Changed governance rules (need merge into already-customized BMAD skill prompts)
- Changed agents (need merge into existing `.github/agents/*.agent.md`)
- Deprecations (files removed in new version)

🛑 **GATE E1: Diff report reviewed.**

### E.3 Apply changes file-by-file with approval

For each diff file, show proposed change, wait for approval, write.

### E.4 Update version stamp

Update `bootstrap_kit_version:` in constitution to `KIT_VERSION`. Commit as `chore: upgrade SDLC kit from <OLD_VERSION> to <KIT_VERSION>`.

End BOOTSTRAP execution.

---

## Phase Z — Kit Metadata and Pinned Versions

```yaml
KIT_VERSION: 0.3.0
KIT_DATE: 2026-05-23
BMAD_VERSION: 6.6.0         # https://github.com/bmad-code-org/BMAD-METHOD/releases
SPECKIT_VERSION: 0.8.7      # https://github.com/github/spec-kit/releases
UNDERSTAND_ANYTHING_VERSION: 2.5.0  # https://github.com/Lum1104/Understand-Anything/releases
```

### Changes from v0.2.0

- Corrected BMAD layout to v6.6 actual (`_bmad/` + `skills/` + `.agents/skills/bmad-*/`, NOT `.bmad-core/`)
- Moved kit agents from `.bmad-additions/agents/*.md` to `.github/agents/*.agent.md` with Copilot frontmatter (this is what makes them `@`-mentionable in Copilot Chat)
- Added explicit note that BMAD personas are reached via skill mechanism, NOT as standalone Copilot agents — SDLC Engine bridges this
- Spec Kit install on Windows uses `uv tool install` (avoids `pip` WinError 5)
- Atomic commit pattern in Phase C.7 / D.9 — one commit per logical chunk so partial failures are recoverable
- Phase B prereqs add `uv` as preferred Python installer

To bump versions, see `UPGRADING.md`.

If you (Copilot) cannot resolve any step above, **stop and ask the user**. Do not improvise on phase boundaries, do not skip gates, do not overwrite existing files in brownfield mode without explicit per-file approval.
