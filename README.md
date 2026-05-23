# SDLC Bootstrap Kit

A reusable bootstrap kit that installs a production-grade AI-SDLC stack (BMAD-METHOD v6 + GitHub Spec Kit + custom governance + missing role agents) into **any project** — greenfield or brownfield — using **GitHub Copilot Agent Mode** in VS Code.

You run **one prompt** (`Execute BOOTSTRAP.md`) and Copilot handles the rest. Approve diffs, swap models for testing, ship.

---

## What's in this kit

```
sdlc-bootstrap-kit/                          ← kit v0.3.0 (BMAD v6.6 layout)
├── README.md                                ← you are here
├── USE-IT.md                                ← 1-page quickstart
├── BOOTSTRAP.md                             ← master prompt Copilot Agent Mode executes
├── UPGRADING.md                             ← how to bump pinned versions
├── install.ps1                              ← Windows one-liner: iwr ... | iex
├── install.sh                               ← Linux/macOS one-liner: curl ... | bash
└── framework/                               ← drop-in folder; copy into your project
    ├── .github/
    │   ├── copilot-instructions.md          ← repo-level Copilot rules
    │   └── agents/                          ← 5 Copilot @-mentionable agents
    │       ├── sdlc-engine.agent.md         ← THE central orchestrator (use this one)
    │       ├── security.agent.md
    │       ├── devops.agent.md
    │       ├── instruction-refactor.agent.md
    │       └── instruction-loop.agent.md
    ├── .bmad-additions/
    │   └── governance-rules.md              ← merged into BMAD persona skills during bootstrap
    ├── .specify/memory/constitution.template.md
    └── docs/templates/
        ├── vision.template.md
        ├── functional-requirements.template.md
        ├── non-functional-requirements.template.md
        └── adr.template.md
```

**BMAD v6.6 layout note:** BMAD's own files install at `_bmad/`, `skills/`, `.agents/skills/bmad-*/`, `bmm/`, `config.toml` — not `.bmad-core/`. BMAD personas (Mary/Preston/Winston/Sally/Simon/Devon/Quinn) are reached via the skill mechanism, NOT as standalone Copilot agents. The SDLC Engine agent bridges this — you `@sdlc-engine` and it routes to the right BMAD persona under the hood.

## Three delivery formats — same content, true one-click

| Format | Best for | How |
|---|---|---|
| **Copilot URL-fetch (recommended)** | Any project, true one-click | Open project in VS Code, Copilot Agent Mode: *"Execute BOOTSTRAP.md from https://github.com/YOU/sdlc-bootstrap-kit"* — Copilot clones, copies, runs, asks per gate |
| **One-liner installer** | When Copilot is flaky or you want a script | Windows: `iwr https://raw.githubusercontent.com/YOU/sdlc-bootstrap-kit/main/install.ps1 \| iex` · Linux/macOS: `curl -fsSL https://.../install.sh \| bash` |
| **GitHub template repo** | Brand-new projects on GitHub | Push this folder to a repo, mark as "Template" in Settings, click "Use this template" |

## How it works

1. You copy the `framework/` folder contents into your project root (preserving the dotfile paths).
2. You also copy `BOOTSTRAP.md` to the project root.
3. You open the project in VS Code, activate Copilot Agent Mode, and prompt: **"Execute BOOTSTRAP.md"**.
4. Copilot Agent Mode detects whether the repo is greenfield (empty) or brownfield (has code/docs/CI) and runs the matching path.
5. You approve diffs as they come. ~3-4 hours of attention for full bootstrap.

## Why this design and not a VS Code extension

A VS Code extension would mean ongoing signing, publishing, marketplace approval, and updates lagging the framework upstream. A markdown-driven kit:

- Updates in seconds (edit a file, commit)
- Works in any IDE that supports Copilot Agent Mode (VS Code, Visual Studio, JetBrains)
- Survives Copilot pricing/feature changes — the prompts are portable to Claude Code, Cursor, Codex
- Inspectable — you can read every instruction Copilot will execute before approving

## Versioning

Tag this repo (or zip filename) with semver. Each project records the version it bootstrapped from in `.specify/memory/constitution.md` under `bootstrap_kit_version:`. To upgrade an existing project, copy in the new `framework/` folder and run `BOOTSTRAP.md` in **upgrade mode** — it will diff and merge.

## License

MIT. Fork it, vendor it, modify it.
