# Upgrading

This kit pins the versions of BMAD-METHOD, GitHub Spec Kit, and understand-anything in `BOOTSTRAP.md` Phase Z. Pinning gives every new project a reproducible bootstrap; unpinning would let upstream churn silently break things.

## When to bump

Bump when:
- An upstream release fixes a bug or vulnerability you've hit
- An upstream release adds a capability you actually want to use
- A pinned version is more than 3 minor releases behind upstream (avoid grand-canyon upgrades)

Do NOT bump just because a new version exists. Pinned reproducibility is the point.

## How to bump (5 minutes)

1. **Pick the target versions** from upstream release pages:
   - BMAD: https://github.com/bmad-code-org/BMAD-METHOD/releases
   - Spec Kit: https://github.com/github/spec-kit/releases
   - understand-anything: https://github.com/Lum1104/Understand-Anything/releases

2. **Update `BOOTSTRAP.md` Phase Z**:
   ```yaml
   KIT_VERSION: <bump kit version per semver>
   BMAD_VERSION: <new>
   SPECKIT_VERSION: <new>
   UNDERSTAND_ANYTHING_VERSION: <new>
   ```
   Kit version semver:
   - PATCH: bump pins only, no template changes
   - MINOR: pin bumps + additive template/agent changes
   - MAJOR: breaking template or governance rule changes

3. **Smoke test** in an empty folder:
   ```bash
   mkdir /tmp/sdlc-smoke && cd /tmp/sdlc-smoke
   git init
   curl -fsSL https://raw.githubusercontent.com/YOUR-USERNAME/sdlc-bootstrap-kit/main/install.sh | bash
   # open in VS Code, run BOOTSTRAP.md against this empty folder
   ```
   Confirm Phase C completes without errors.

4. **Document breaking changes** in `CHANGELOG.md` (create if absent). Each kit version gets one entry. Specifically call out:
   - New required environment variables
   - Removed agents or templates
   - Governance rules that changed default behavior
   - Migration steps for existing projects on the prior version

5. **Tag and push:**
   ```bash
   git commit -am "chore: bump to kit v<X.Y.Z>"
   git tag v<X.Y.Z>
   git push --tags
   ```

## Upgrading an existing project that was bootstrapped from a prior kit version

In the project, in Copilot Agent Mode:

> "Execute BOOTSTRAP.md in upgrade mode. Source the latest kit from https://github.com/YOUR-USERNAME/sdlc-bootstrap-kit branch main."

Phase E in `BOOTSTRAP.md` handles the diff-and-merge with per-file approval. The kit version stamped in `.specify/memory/constitution.md` tells Copilot the starting point.

## Avoiding upgrade fatigue

- Subscribe only to upstream release notifications, not commit activity
- Bump on your schedule, not theirs — weekly check-in maximum
- If an upstream release has a CVE, bump within 1 business day
- If an upstream release has only feature adds, batch with the next scheduled bump
