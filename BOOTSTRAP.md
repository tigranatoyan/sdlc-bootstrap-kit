# BOOTSTRAP.md — Master Prompt for Copilot Agent Mode

> **You are GitHub Copilot in VS Code Agent Mode.** This file is your end-to-end instruction set for installing the SDLC framework into this repository. Execute the phases below in order. **Stop and ask the user** at every gate marked `🛑 GATE`. **Approve nothing destructive without explicit user confirmation.**

---

## Phase 0 — Source-of-Truth Resolution (always first)

Determine whether the kit files are already in this repo or need to be fetched from a URL.

```
RUN: check if `framework/` directory exists in the current repo root
RUN: check if `.bmad-additions/governance-rules.md` exists
```

If the framework files are **present locally**, proceed to Phase A.

If the framework files are **absent**, switch to URL-FETCH MODE:

1. Ask the user: "I do not see the framework files locally. Fetch them from the SDLC Bootstrap Kit repository? Default URL: `https://github.com/tigranatoyan/sdlc-bootstrap-kit` (branch: `main`). Confirm URL or override."
2. With approved URL `<KIT_URL>` and branch `<KIT_BRANCH>`:
   ```bash
   git clone --depth 1 --branch <KIT_BRANCH> <KIT_URL> /tmp/sdlc-kit
   ```
3. Copy framework files into the current repo:
   - **Greenfield (current dir is empty/clean):** `cp -r /tmp/sdlc-kit/framework/. .`
   - **Brownfield (current dir has existing files):** stop and ask user for per-conflict approval. Use the kit's `framework/` as the source; for each file, if target exists, show diff and ask; if target is missing, copy.
4. Copy `BOOTSTRAP.md` from `/tmp/sdlc-kit/BOOTSTRAP.md` to current dir, overwriting only with approval if it differs.
5. Record kit version: read `KIT_VERSION` from the fetched `BOOTSTRAP.md` Phase Z, remember for Phase C.8 / D.6 constitution stamping.
6. Proceed to Phase A.

🛑 **GATE 0:** URL and version confirmed before any file copy.

---

## Phase A — Mode Detection (always first)

Before doing anything else, detect the project mode.

```
RUN: list contents of the current directory
RUN: check git status
```

Decision tree:

- **GREENFIELD MODE** if all of:
  - No files under `src/`, `app/`, `apps/`, `services/`, `packages/`, `lib/` (or those dirs don't exist)
  - No `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `pom.xml`, or `Gemfile`
  - No `docs/` content beyond `docs/templates/`
  - No `.github/workflows/` content
- **BROWNFIELD MODE** otherwise
- **UPGRADE MODE** if `.specify/memory/constitution.md` already exists with a `bootstrap_kit_version:` line

State the detected mode to the user explicitly, then say:

> "Detected mode: `<MODE>`. I will follow the `<MODE>` path. Confirm to proceed, or override by saying 'use <other> mode'."

🛑 **GATE 1: Mode confirmation.** Do not proceed without explicit "yes" or override.

---

## Phase B — Common Prerequisites (run for all modes)

Check that these are installed; offer to install any that are missing:

- `node` v20+ (`node --version`)
- `npm` (`npm --version`)
- `pipx` (`pipx --version`) — fallback to `pip` if absent
- `gh` (GitHub CLI) (`gh --version`)
- `claude` (Claude Code CLI) (`claude --version`)

If any are missing, present the install commands and wait for user approval before running.

🛑 **GATE 2: Prerequisites confirmed.**

---

## Phase C — GREENFIELD PATH

Skip if not greenfield.

### C.1 Install BMAD-METHOD v6 (pinned)

```bash
npx bmad-method@${BMAD_VERSION} install --preset greenfield-fullstack --ide vscode --non-interactive
```

Use `BMAD_VERSION` from Phase Z. After install, list what was added and confirm the version installed matches.

### C.2 Install GitHub Spec Kit (pinned)

```bash
pipx install --force "specify-cli==${SPECKIT_VERSION}"
specify init --here --ai copilot
```

Use `SPECKIT_VERSION` from Phase Z.

### C.3 Move kit's framework files into place

The user has already copied `framework/` contents to the repo root. Verify:

- `.specify/memory/constitution.template.md` exists
- `.bmad-additions/` exists
- `.github/copilot-instructions.md` exists
- `docs/templates/` has the four template files

If any are missing, stop and tell the user.

### C.4 Fold governance rules into BMAD agents

Read `.bmad-additions/governance-rules.md`. For each agent file under `.bmad-core/agents/`, merge the governance rules into its `<rules>` section. **Do not** alter persona, lifecycle, or handoff schema. Show the user the diff per file. After approval, apply.

### C.5 Install the four missing agents

Move `.bmad-additions/agents/*.md` to `.bmad-core/agents/` and register each in `.bmad-core/agent-teams/team-fullstack.yaml`. Show the YAML diff before applying.

### C.6 Install understand-anything plugin (via Claude Code as host)

```bash
claude plugin marketplace add Lum1104/Understand-Anything
claude plugin install understand-anything
```

Add `understand-anything-output/` to `.gitignore`.

### C.7 First commit

Stage everything, commit as: `chore: bootstrap SDLC framework v<KIT_VERSION>`. Do NOT push without user approval.

🛑 **GATE 3: Framework installed.**

### C.8 Constitution interview

This is the load-bearing step. Open `.specify/memory/constitution.template.md`. Interview the user one section at a time. Do not write any section without their answer. Cover every section in the template. After each section, draft it inline and wait for "ok" before moving to the next.

When complete, write `.specify/memory/constitution.md` (not `.template.md`), set `bootstrap_kit_version:` to the kit version, commit as: `docs: project constitution v1.0.0`.

🛑 **GATE 4: Constitution complete.**

### C.9 Hand off to BMAD lifecycle

Tell the user:

> "Framework is installed and the constitution is set. To generate Shawarma artifacts from scratch, switch model to **Claude Opus 4.6** and prompt me: **'Activate BMAD Analyst (Mary) and interview me for Vision.'** From there the BMAD lifecycle takes over: Vision → FRs → NFRs+Architecture → Backlog → per-story implementation."

End BOOTSTRAP execution.

---

## Phase D — BROWNFIELD PATH

Skip if not brownfield.

### D.1 Reconnaissance (read-only)

Inventory what already exists. Produce a short report:

- Language(s) and frameworks (from package manifests)
- Existing CI workflows under `.github/workflows/`
- Existing docs under `docs/` and root-level `*.md`
- Test framework(s) detected
- Lint/formatter configs detected
- Existing `.github/copilot-instructions.md` or `.cursorrules` or `CLAUDE.md`

Show the report. **No file changes yet.**

🛑 **GATE D1: Reconnaissance reviewed.**

### D.2 Install BMAD-METHOD v6 in brownfield mode (pinned)

```bash
npx bmad-method@${BMAD_VERSION} install --preset brownfield --ide vscode --non-interactive
```

The brownfield preset is more conservative: it does not assume project structure. Use `BMAD_VERSION` from Phase Z.

### D.3 Install Spec Kit (pinned)

```bash
pipx install --force "specify-cli==${SPECKIT_VERSION}"
specify init --here --ai copilot
```

### D.4 Merge kit's framework files non-destructively

For each file in `framework/`:
- If the target path does NOT exist → copy.
- If the target path EXISTS → produce a three-way merge proposal and ask the user before writing.

Specifically:
- `.github/copilot-instructions.md` — append kit content under a `## SDLC Framework Rules` section if file exists, else create.
- `docs/templates/*.template.md` — create only if missing.

### D.5 Run understand-anything to graph the existing code

```bash
claude plugin marketplace add Lum1104/Understand-Anything
claude plugin install understand-anything
claude /understand
```

This produces a knowledge graph the next agents will use as context.

### D.6 Reverse-engineer Vision and Constitution

Activate the BMAD Analyst agent. Interview the user, but **prime the interview with what was found**:

> "I've read your existing README, docs, and code. Based on that I drafted a candidate Vision and Constitution. Walk through each section with me — confirm, correct, or expand."

For each candidate section, present the draft and the source files/lines you derived it from. Get user approval before writing.

Write to:
- `docs/VISION.md`
- `.specify/memory/constitution.md` (with `bootstrap_kit_version:` set)

🛑 **GATE D2: Vision and Constitution confirmed.**

### D.7 Reverse-engineer FRs, NFRs, and Architecture

Activate BMAD PM (FRs), then Architect (NFRs + architecture). Both should read the knowledge graph from understand-anything and the existing code, and produce *as-built* documents that reflect what the code actually does — flagging any gaps or contradictions.

Write to:
- `docs/FUNCTIONAL_REQUIREMENTS.md`
- `docs/NON_FUNCTIONAL_REQUIREMENTS.md`
- `docs/architecture/*.md` (C4 levels, runtime view, deployment view, data model)
- `docs/architecture/decisions/ADR-XXXX-*.md` (one ADR per non-trivial decision detected)

Each artifact must include an `## As-Built vs Intended` section flagging where the code diverges from what *should* be there.

🛑 **GATE D3: As-built documents reviewed.**

### D.8 Add missing CI/CD gates non-destructively

Activate the DevOps agent. Read existing `.github/workflows/`. Add only what's missing:
- `architecture-fitness.yml` (if absent)
- `security.yml` (if no Snyk/CodeQL workflow exists)

Do NOT touch existing `ci.yml`, `release.yml`, etc.

### D.9 First commit

Stage and commit as: `chore: layer SDLC framework into brownfield repo v<KIT_VERSION>`.

🛑 **GATE D4: Brownfield bootstrap complete.**

### D.10 Hand off to daily loop

Tell the user:

> "Framework is layered on top of your existing code. The as-built docs are now your starting baseline. To start improving them or to ship the next feature using the framework, prompt me: **'Pick the highest-priority gap from the as-built reports and propose a story for it.'**"

End BOOTSTRAP execution.

---

## Phase E — UPGRADE PATH

Skip if not upgrade.

### E.1 Read current version

Read `.specify/memory/constitution.md` → `bootstrap_kit_version:` value. Call this `OLD_VERSION`. The kit's current version is in `KIT_VERSION` (defined at the top of this file — see Phase Z).

### E.2 Diff the framework folder

For each file in `framework/`, compare with the target file in the project. Produce a diff report grouped by:
- New files (additive — safe)
- Changed templates (need merge)
- Changed governance rules (need merge into already-customized BMAD agents)
- Deprecations (files removed in new version)

🛑 **GATE E1: Diff report reviewed.**

### E.3 Apply changes file-by-file with approval

For each file in the diff, show the proposed change and wait for user approval before writing.

### E.4 Update version stamp

Update `bootstrap_kit_version:` in the constitution to `KIT_VERSION`. Commit as: `chore: upgrade SDLC kit from <OLD_VERSION> to <KIT_VERSION>`.

End BOOTSTRAP execution.

---

## Phase Z — Kit Metadata and Pinned Versions

```yaml
KIT_VERSION: 0.2.0
KIT_DATE: 2026-05-23
BMAD_VERSION: 6.6.0         # https://github.com/bmad-code-org/BMAD-METHOD/releases
SPECKIT_VERSION: 0.8.7      # https://github.com/github/spec-kit/releases
UNDERSTAND_ANYTHING_VERSION: 2.5.0  # https://github.com/Lum1104/Understand-Anything/releases
```

To bump versions, see `UPGRADING.md` in the kit root.

If you (Copilot) cannot resolve any step above, **stop and ask the user**. Do not improvise on phase boundaries, do not skip gates, do not overwrite existing files in brownfield mode without explicit per-file approval.
