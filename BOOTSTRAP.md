# BOOTSTRAP.md — Master Prompt for Copilot Agent Mode (v0.4.0)

> **You are GitHub Copilot in VS Code Agent Mode.** This file is your end-to-end instruction set for installing the SDLC framework. **After every numbered phase below**, you MUST run `pwsh ./scripts/verify-bootstrap.ps1 -Stage <stage>` and PROCEED ONLY ON `VERDICT: READY`. If a stage returns `NOT READY`, STOP, report the failed checks, and ask the user before continuing or attempting a fix. Do not chain phases on broken state.

> **BMAD v6.6 layout note:** BMAD installs at `_bmad/` (core) + `.agents/skills/bmad-*/` (persona skill packs) + `bmm/` + `config.toml`. Personas (Mary/Preston/Winston/Sally/Simon/Devon/Quinn) are reached via the BMAD skill mechanism, NOT as standalone Copilot agents. Copilot-invocable agents live in `.github/agents/*.agent.md`. SDLC Engine (`@sdlc-engine`) is the bridge that routes user prompts to the right BMAD persona under the hood.

---

## Self-verification protocol (applies to every phase)

After each phase below finishes, run:

```powershell
pwsh ./scripts/verify-bootstrap.ps1 -Stage <stage-name>
```

The script outputs `VERDICT: READY` or `VERDICT: NOT READY`. **Do not advance** until READY. If NOT READY, halt and ask the user. The script exit code is non-zero on failure, so if invoked via shell you should treat that as a hard stop.

Stage names map to phases as listed in each section heading below.

---

## Phase 0 — Source-of-Truth Resolution + verify-script bootstrap

```
RUN: check if `.github/agents/sdlc-engine.agent.md` exists in this repo
RUN: check if `.bmad-additions/governance-rules.md` exists
RUN: check if `scripts/verify-bootstrap.ps1` exists
```

If files are **present locally**, proceed to Phase A.

If files are **absent**, switch to URL-FETCH MODE:

1. Ask user: "Fetch from SDLC Bootstrap Kit? Default URL: `https://github.com/YOUR-USERNAME/sdlc-bootstrap-kit` (branch: `main`). Confirm URL or override."
2. With approved URL `<KIT_URL>` and branch `<KIT_BRANCH>`:
   ```bash
   git clone --depth 1 --branch <KIT_BRANCH> <KIT_URL> /tmp/sdlc-kit
   ```
3. Copy framework files into current repo:
   - **Greenfield (current dir clean):** `cp -r /tmp/sdlc-kit/framework/. .`
   - **Brownfield (current dir has files):** stop and ask per-conflict approval. Use kit's `framework/` as source; for each file, if target exists show diff and ask; if target missing, copy.
4. Copy `BOOTSTRAP.md` from `/tmp/sdlc-kit/BOOTSTRAP.md` to current dir if differs (with approval).
5. **Verify `scripts/verify-bootstrap.ps1` is now present in the repo.** It must exist before Phase B. If not, stop and ask user.
6. Record kit version from Phase Z.

🛑 **GATE 0:** URL confirmed and verify-bootstrap.ps1 present.

---

## Phase A — Mode Detection

```
RUN: list contents of current directory
RUN: check git status
```

Decision tree:
- **GREENFIELD MODE** if: no `src/`, `app/`, `apps/`, `services/`, `packages/`, `lib/` content AND no `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `pom.xml`, `Gemfile` AND no `docs/` content beyond `docs/templates/` AND no `.github/workflows/` content.
- **BROWNFIELD MODE** otherwise.
- **UPGRADE MODE** if `.specify/memory/constitution.md` exists with `bootstrap_kit_version:` line.

State mode explicitly, ask user to confirm:

> "Detected mode: `<MODE>`. Confirm to proceed, or override by saying 'use <other> mode'."

🛑 **GATE 1: Mode confirmation.**

---

## Phase B — Common Prerequisites

Check installed, offer to install missing:

- `node` v20+
- `npm`
- `git`
- `pipx` OR `uv` (prefer `uv` on Windows — avoids pip WinError 5)
- `gh` (GitHub CLI)
- `claude` (Claude Code CLI)

If missing, present install commands and wait for approval.

🛑 **GATE 2: Prerequisites confirmed.**

### ✅ VERIFY — Stage `prereqs`

```powershell
pwsh ./scripts/verify-bootstrap.ps1 -Stage prereqs
```

Expected: PASS on all five required CLIs (node, npm, git, gh, claude). uv and pipx are WARN-acceptable individually (at least one of them must be installable).

If FAIL: halt, list missing CLIs, ask user to install before continuing.

---

## Phase C — GREENFIELD PATH

Skip if not greenfield.

### C.1 Install BMAD-METHOD v6 (pinned)

```bash
npx --yes bmad-method@${BMAD_VERSION} install --preset greenfield-fullstack --ide vscode --non-interactive
```

After install, list what was added.

#### ✅ VERIFY — Stage `bmad-install`

```powershell
pwsh ./scripts/verify-bootstrap.ps1 -Stage bmad-install
```

Expected: PASS on `_bmad/core`, `_bmad/bmm`, `_bmad/config.toml`, persona skills count ≥ 7. WARN-acceptable on any missing canonical persona (Copilot reports which).

If FAIL: BMAD install was incomplete or wrong version. Halt, capture stdout/stderr from `npx`, ask user.

---

### C.2 Install GitHub Spec Kit (pinned)

```bash
uv tool install "specify-cli==${SPECKIT_VERSION}" || pipx install --force "specify-cli==${SPECKIT_VERSION}"
specify init --here --ai copilot
```

#### ✅ VERIFY — Stage `speckit-install`

```powershell
pwsh ./scripts/verify-bootstrap.ps1 -Stage speckit-install
```

Expected: PASS on `.specify/`, `.specify/memory/`, constitution template. WARN-acceptable on slash command count.

If FAIL: halt, capture install output, ask user.

---

### C.3 Verify kit framework files in place

```powershell
pwsh ./scripts/verify-bootstrap.ps1 -Stage framework-files
```

Expected: PASS on all 5 kit agents, governance-rules.md, copilot-instructions.md, 4 doc templates, frontmatter parses on each agent.

If FAIL: kit files missing or corrupt. Halt — likely Phase 0 didn't fetch/copy completely. Ask user.

---

### C.4 Merge kit governance rules into BMAD persona skill prompts

Read `.bmad-additions/governance-rules.md`. For each BMAD persona skill pack under `.agents/skills/bmad-agent-*/`, identify the persona's prompt file (typically `SKILL.md` inside the skill directory). Append the relevant governance rules under a `## Governance Rules (from SDLC Bootstrap Kit)` section heading. Do NOT alter the persona's identity or workflow — only add rules.

Show user the diff per persona before applying. After approval, apply.

#### ✅ VERIFY — Stage `governance-merge`

```powershell
pwsh ./scripts/verify-bootstrap.ps1 -Stage governance-merge
```

Expected: PASS on `Personas with governance merged >= 5` (checks for the `Governance Rules` heading marker in each persona's prompt files).

If FAIL: the merge step was skipped or didn't write to the right files. Halt, ask user to inspect.

---

### C.5 Confirm Copilot agent registration (readiness check, no install action)

Tell user: "Close and reopen Copilot Chat panel (or `Ctrl+Shift+P` → 'Developer: Reload Window'). Type `@sdlc` in chat input. Confirm `@sdlc-engine` appears in the dropdown (it may show with the `.agent.md` file path; that's fine — it works via file-attach pattern)."

Wait for user confirmation. If user says no, troubleshoot with frontmatter inspection. Do NOT proceed until user confirms.

---

### C.6 (Optional) Install understand-anything plugin

Skip on Windows (known scanner hang). On Linux/macOS:

```bash
claude plugin marketplace add Lum1104/Understand-Anything
claude plugin install understand-anything
```

Add `understand-anything-output/`, `.understandignore`, `intermediate/`, `tmp/` to `.gitignore`.

---

### C.7 Import artifacts to docs/ (if user provided pre-authored content)

If user indicated they have pre-authored Vision / FRs / NFRs / etc. in `Initial Input/` or elsewhere, copy them to canonical `docs/` locations per the user's import instructions in their initial prompt.

If no pre-authored artifacts: skip this step (and the verify below).

#### ✅ VERIFY — Stage `imports` (skip if user provided no imports)

```powershell
pwsh ./scripts/verify-bootstrap.ps1 -Stage imports
```

Expected: PASS on all expected `docs/*.md` files matching the user's import list. WARN-acceptable on line-count drift (refinement allowed).

If FAIL: imports incomplete. Halt, list missing files, ask user.

---

### C.8 Constitution authoring (interview OR derive from imports)

Two modes:

**C.8a — INTERVIEW** (no imports, or constitution doesn't exist):
Open `.specify/memory/constitution.template.md`. Interview user one section at a time. Do not write any section without their answer. After each section, draft inline and wait for "ok".

**C.8b — DERIVE FROM IMPORTS** (user has imported requirements):
Read all imported `docs/*.md`. Draft `.specify/memory/constitution.md` filling every section you can from the evidence, citing source files per section. Ask user only for sections that have no source in their artifacts (typically: deployment target, hosting, observability stack, branching policy, cadence).

When complete, write `.specify/memory/constitution.md`, set `bootstrap_kit_version:` to `KIT_VERSION` from Phase Z.

#### ✅ VERIFY — Stage `constitution`

```powershell
pwsh ./scripts/verify-bootstrap.ps1 -Stage constitution
```

Expected: PASS on file exists, bootstrap_kit_version stamped, project_name set, section count ≥ 10, length ≥ 100 lines.

If FAIL: constitution incomplete or unstamped. Halt, fix the missing fields, ask user.

---

### C.9 Atomic commits

Stage and commit in this order:

1. `chore: install BMAD-METHOD v${BMAD_VERSION}` — `_bmad/`, `.agents/skills/bmad-*/`, .gitignore additions
2. `chore: install Spec Kit v${SPECKIT_VERSION}` — `.specify/` scaffolding except constitution.md
3. `feat: install SDLC kit framework files` — `.github/agents/*.agent.md`, `.github/copilot-instructions.md`, `.bmad-additions/governance-rules.md`, `docs/templates/*`, `scripts/verify-bootstrap.ps1`
4. `feat: merge SDLC governance into BMAD persona skills` — modifications to `.agents/skills/bmad-agent-*/`
5. `feat: import pre-authored requirement artifacts to docs/` — `docs/*.md` imports (if applicable)
6. `docs: project constitution v1.0.0` — `.specify/memory/constitution.md`

Do NOT push without user approval.

#### ✅ VERIFY — Stage `atomic-commits`

```powershell
pwsh ./scripts/verify-bootstrap.ps1 -Stage atomic-commits
```

Expected: PASS on commit count ≥ 5, working tree clean, all 5 commit pattern matches found.

If FAIL: commit chain malformed or working tree dirty. Halt, list missing patterns, ask user.

---

### C.10 FINAL verification

```powershell
pwsh ./scripts/verify-bootstrap.ps1 -Stage final
```

Expected: PASS on the full bootstrap invariant set (all of: bmad-install, speckit-install, framework-files, governance-merge, imports, constitution, initial-input-preserved, atomic-commits).

If FAIL: bootstrap not in a known-good state. Halt, list all FAIL items, ask user.

🛑 **GATE 3: Final bootstrap verification PASSED.**

---

### C.11 Handoff to SDLC Engine

Tell user:

> "Bootstrap complete and verified. To run the pipeline:
> 1. Reload Copilot panel (Ctrl+Shift+P → Developer: Reload Window)
> 2. Switch model to **Claude Opus 4.6** for architecture-grade reasoning
> 3. Attach `.github/agents/sdlc-engine.agent.md` to your prompt (type `@`, select the file)
> 4. Prompt: 'Act as the SDLC Engine persona defined in the attached file. Pipeline mode. Validate imported FRs/NFRs (do not re-author), then proceed to Architecture phase. Stop after every phase. Stop at ready-for-development gate.'
> 5. After pipeline completes, run: `pwsh ./scripts/verify-bootstrap.ps1 -Stage pre-coding` to confirm readiness for sprint 1."

End BOOTSTRAP execution.

---

## Phase D — BROWNFIELD PATH

Skip if not brownfield. Same per-phase verification pattern as Phase C, with these differences:

- D.1 Reconnaissance (no install, no verify)
- D.2 BMAD install with `--preset brownfield` → verify `bmad-install`
- D.3 Spec Kit install → verify `speckit-install`
- D.4 Merge kit framework files non-destructively (per-conflict approval) → verify `framework-files`
- D.5 (Optional) Understand-anything → skip on Windows
- D.6 Reverse-engineer Vision + Constitution from existing code → verify `constitution`
- D.7 Reverse-engineer FRs/NFRs/Architecture as as-built → verify `imports` (if applicable)
- D.8 Add missing CI/CD gates (no verify yet; covered later in `sprint-1`)
- D.9 Atomic commits → verify `atomic-commits`
- D.10 FINAL → verify `final`

Same self-verification protocol applies after every phase.

---

## Phase E — UPGRADE PATH

Skip if not upgrade. Read current `bootstrap_kit_version`, diff against current kit, apply changes with per-file approval, update version stamp, commit, verify `final`.

---

## Phase Z — Kit Metadata and Pinned Versions

```yaml
KIT_VERSION: 0.4.0
KIT_DATE: 2026-05-23
BMAD_VERSION: 6.6.0
SPECKIT_VERSION: 0.8.7
UNDERSTAND_ANYTHING_VERSION: 2.5.0
```

### Changes from v0.3.0

- **Self-verification is baked into the flow.** Each phase ends with `pwsh ./scripts/verify-bootstrap.ps1 -Stage <stage>`. Copilot runs it automatically and HALTS on FAIL — you don't alt-tab to a separate script.
- **Verify script ships in the framework** at `scripts/verify-bootstrap.ps1`, so it's available from the very first phase.
- **Per-stage check modes**: `prereqs`, `bmad-install`, `speckit-install`, `framework-files`, `governance-merge`, `imports`, `constitution`, `atomic-commits`, `final`, `pre-coding`, `sprint-1`.
- C.7 split into imports (C.7) + constitution (C.8) + commits (C.9) for finer-grained verification.
- C.10 explicit `final` verification before handoff.
- C.11 handoff now reminds user to run `-Stage pre-coding` after SDLC Engine pipeline completes.

To bump pinned versions, see `UPGRADING.md`.

If you (Copilot) cannot resolve any verification failure, **stop and ask the user**. Do not improvise on phase boundaries, do not skip gates, do not declare success without the script's `VERDICT: READY`.
