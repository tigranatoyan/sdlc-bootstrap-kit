# Quickstart — Use the SDLC Bootstrap Kit

## For a NEW project (greenfield)

```bash
# 1. Create empty project folder
mkdir my-new-project && cd my-new-project
git init

# 2. Drop in the kit (pick one)
# Option A: clone this kit and copy
git clone https://github.com/tigranatoyan/sdlc-bootstrap-kit /tmp/sdlc-kit
cp -r /tmp/sdlc-kit/framework/. .
cp /tmp/sdlc-kit/BOOTSTRAP.md .

# Option B: unzip a downloaded zip
unzip ~/Downloads/sdlc-bootstrap-kit.zip -d /tmp/sdlc-kit
cp -r /tmp/sdlc-kit/framework/. .
cp /tmp/sdlc-kit/BOOTSTRAP.md .

# 3. Open in VS Code
code .
```

In VS Code:
1. Open Copilot Chat → switch to **Agent Mode**
2. Select model **Claude Sonnet 4.6**
3. Prompt: **"Execute BOOTSTRAP.md. This is a new project."**
4. Approve diffs as they appear

That's it. Total attention: ~3.5 hours over the bootstrap. After that you're in the daily story-implementation loop.

---

## For an EXISTING project (brownfield, mid-stream)

Same first 3 steps as greenfield, but the prompt is different:

```bash
cd path/to/existing-project
cp -r /tmp/sdlc-kit/framework/. .
cp /tmp/sdlc-kit/BOOTSTRAP.md .
code .
```

In VS Code:
1. Copilot Chat → **Agent Mode** → **Claude Sonnet 4.6**
2. Prompt: **"Execute BOOTSTRAP.md. This is an existing project — detect what's already here and merge non-destructively."**

What happens differently in brownfield mode:
- **No file is overwritten** without your approval
- Existing CI workflows are preserved; new ones (security, fitness, architecture) are added alongside
- Existing `docs/` is read first; constitution and vision are *extracted* from existing content where possible, not invented from scratch
- understand-anything plugin runs *first* to build a knowledge graph; that graph then feeds the Architect agent's reverse-engineering of the architecture document
- Existing `.github/copilot-instructions.md` is merged, not replaced
- Existing tests, lint rules, formatter configs are preserved

---

## Daily loop (after bootstrap, any project)

1. Open project in VS Code
2. Copilot Agent Mode, model varies by task
3. Prompt: **"Implement the next ready story."**
4. Approve PR diff. Merge.

---

## Upgrading the kit in an existing project

When this kit ships a new version:

```bash
cd /tmp/sdlc-kit && git pull
cd ~/path/to/your-project
cp -r /tmp/sdlc-kit/framework/. .  # copies new files, you'll get git diffs for changed ones
```

Then in VS Code Copilot Agent Mode: **"Execute BOOTSTRAP.md in upgrade mode."** It will diff the new framework files against your current ones and merge changes without breaking your customizations.
