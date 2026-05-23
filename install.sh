#!/usr/bin/env bash
# SDLC Bootstrap Kit — bash installer
# Usage (one-liner, run from your project folder):
#   curl -fsSL https://raw.githubusercontent.com/YOUR-USERNAME/sdlc-bootstrap-kit/main/install.sh | bash
#
# What it does:
# 1. Clones the kit into a temp folder
# 2. Copies framework/ contents and BOOTSTRAP.md into the current directory
# 3. Detects greenfield vs brownfield and prints the next step for Copilot Agent Mode
#
# Safe by default: never overwrites existing files in brownfield mode.

set -euo pipefail

# --- CONFIG (override via env vars) ---
KIT_REPO="${SDLC_KIT_REPO:-https://github.com/YOUR-USERNAME/sdlc-bootstrap-kit}"
KIT_BRANCH="${SDLC_KIT_BRANCH:-main}"
TEMP_DIR="$(mktemp -d -t sdlc-kit-XXXXXX)"

# Colors
C_CYAN='\033[0;36m'; C_YELLOW='\033[1;33m'; C_GREEN='\033[0;32m'
C_RED='\033[0;31m'; C_GRAY='\033[0;90m'; C_DYELLOW='\033[0;33m'; C_RESET='\033[0m'

echo -e "${C_CYAN}SDLC Bootstrap Kit installer${C_RESET}"
echo "  Source:  $KIT_REPO (branch: $KIT_BRANCH)"
echo "  Target:  $(pwd)"
echo ""

# --- prerequisite check ---
command -v git >/dev/null 2>&1 || { echo "git is required but not installed." >&2; exit 1; }

# --- mode detection ---
IS_BROWNFIELD=0
for f in package.json pyproject.toml Cargo.toml go.mod pom.xml Gemfile; do
  [[ -f "$f" ]] && IS_BROWNFIELD=1
done
for d in src app apps services packages lib; do
  [[ -d "$d" ]] && IS_BROWNFIELD=1
done

if [[ $IS_BROWNFIELD -eq 1 ]]; then
  MODE="BROWNFIELD"
else
  MODE="GREENFIELD"
fi
echo -e "  Mode:    ${C_YELLOW}${MODE}${C_RESET}"
echo ""

# --- clone kit ---
echo -e "${C_GRAY}Cloning kit into $TEMP_DIR...${C_RESET}"
git clone --depth 1 --branch "$KIT_BRANCH" "$KIT_REPO" "$TEMP_DIR" >/dev/null 2>&1

# --- copy files ---
COPIED=0; CONFLICTS=0
SOURCE="$TEMP_DIR/framework"

# Find every file under framework/ (including dotfiles), preserving structure
while IFS= read -r -d '' src_file; do
  rel="${src_file#$SOURCE/}"
  target="$(pwd)/$rel"
  target_dir="$(dirname "$target")"
  mkdir -p "$target_dir"

  if [[ -e "$target" ]]; then
    if [[ $IS_BROWNFIELD -eq 1 ]]; then
      echo -e "  ${C_RED}CONFLICT (skipped):${C_RESET} $rel"
      CONFLICTS=$((CONFLICTS + 1))
    else
      cp -f "$src_file" "$target"
      echo -e "  ${C_DYELLOW}OVERWROTE:${C_RESET} $rel"
      COPIED=$((COPIED + 1))
    fi
  else
    cp "$src_file" "$target"
    echo -e "  ${C_GREEN}ADDED:${C_RESET} $rel"
    COPIED=$((COPIED + 1))
  fi
done < <(find "$SOURCE" -type f -print0)

# Copy BOOTSTRAP.md to root
if [[ -e "BOOTSTRAP.md" ]]; then
  echo -e "  ${C_YELLOW}BOOTSTRAP.md already exists; left as-is. Compare with $TEMP_DIR/BOOTSTRAP.md if needed.${C_RESET}"
else
  cp "$TEMP_DIR/BOOTSTRAP.md" "BOOTSTRAP.md"
  echo -e "  ${C_GREEN}ADDED:${C_RESET} BOOTSTRAP.md"
  COPIED=$((COPIED + 1))
fi

# --- cleanup ---
rm -rf "$TEMP_DIR"

# --- summary ---
echo ""
echo -e "${C_CYAN}Summary:${C_RESET}"
echo "  Files added/overwritten: $COPIED"
echo "  Conflicts skipped:       $CONFLICTS"
echo ""
echo -e "${C_CYAN}Next step:${C_RESET}"
echo "  1. Open this folder in VS Code:  code ."
echo "  2. Open Copilot Chat -> Agent Mode -> select Claude Sonnet 4.6"
if [[ $IS_BROWNFIELD -eq 1 ]]; then
  echo "  3. Prompt: 'Execute BOOTSTRAP.md. This is an existing project -- detect what is already here and merge non-destructively.'"
  if [[ $CONFLICTS -gt 0 ]]; then
    echo -e "  ${C_YELLOW}NOTE: $CONFLICTS file(s) had conflicts and were skipped. BOOTSTRAP.md will ask about each one when it runs.${C_RESET}"
  fi
else
  echo "  3. Prompt: 'Execute BOOTSTRAP.md. This is a new project.'"
fi
