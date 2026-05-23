# SDLC Bootstrap Kit — PowerShell installer
# Usage (one-liner, run from your project folder):
#   iwr https://raw.githubusercontent.com/tigranatoyan/sdlc-bootstrap-kit/main/install.ps1 | iex
#
# What it does:
# 1. Clones the kit into a temp folder
# 2. Copies framework/ contents and BOOTSTRAP.md into the current directory
# 3. Detects greenfield vs brownfield and prints the next step for Copilot Agent Mode
#
# Safe by default: never overwrites existing files in brownfield mode.

$ErrorActionPreference = "Stop"

# --- CONFIG (override via env vars) ---
$KitRepo   = if ($env:SDLC_KIT_REPO)   { $env:SDLC_KIT_REPO }   else { "https://github.com/tigranatoyan/sdlc-bootstrap-kit" }
$KitBranch = if ($env:SDLC_KIT_BRANCH) { $env:SDLC_KIT_BRANCH } else { "main" }
$TempDir   = Join-Path $env:TEMP "sdlc-kit-$(Get-Random)"

Write-Host "SDLC Bootstrap Kit installer" -ForegroundColor Cyan
Write-Host "  Source:  $KitRepo (branch: $KitBranch)"
Write-Host "  Target:  $((Get-Location).Path)"
Write-Host ""

# --- prerequisite check ---
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "git is required but not installed. Install: winget install --id Git.Git"
    exit 1
}

# --- mode detection ---
$ProjectFiles = Get-ChildItem -File -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -in @('package.json','pyproject.toml','Cargo.toml','go.mod','pom.xml','Gemfile')
}
$ProjectDirs  = Get-ChildItem -Directory -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -in @('src','app','apps','services','packages','lib')
}
$IsBrownfield = ($ProjectFiles.Count -gt 0) -or ($ProjectDirs.Count -gt 0)
$Mode = if ($IsBrownfield) { "BROWNFIELD" } else { "GREENFIELD" }
Write-Host "  Mode:    $Mode" -ForegroundColor Yellow
Write-Host ""

# --- clone kit ---
Write-Host "Cloning kit into $TempDir..." -ForegroundColor Gray
git clone --depth 1 --branch $KitBranch $KitRepo $TempDir 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) { Write-Error "Clone failed."; exit 1 }

# --- copy files ---
$Source = Join-Path $TempDir "framework"
$CopiedCount = 0; $SkippedCount = 0; $ConflictCount = 0

Get-ChildItem -Path $Source -Recurse -File | ForEach-Object {
    $Relative = $_.FullName.Substring($Source.Length + 1)
    $Target   = Join-Path (Get-Location) $Relative
    $TargetDir = Split-Path $Target -Parent
    if (-not (Test-Path $TargetDir)) { New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null }

    if (Test-Path $Target) {
        if ($IsBrownfield) {
            Write-Host "  CONFLICT (skipped): $Relative" -ForegroundColor Red
            $ConflictCount++
        } else {
            Copy-Item -Path $_.FullName -Destination $Target -Force
            Write-Host "  OVERWROTE: $Relative" -ForegroundColor DarkYellow
            $CopiedCount++
        }
    } else {
        Copy-Item -Path $_.FullName -Destination $Target
        Write-Host "  ADDED: $Relative" -ForegroundColor Green
        $CopiedCount++
    }
}

# Copy BOOTSTRAP.md to root
$BootstrapTarget = Join-Path (Get-Location) "BOOTSTRAP.md"
if (Test-Path $BootstrapTarget) {
    Write-Host "  BOOTSTRAP.md already exists; left as-is. Use kit version at $TempDir\BOOTSTRAP.md to compare." -ForegroundColor Yellow
} else {
    Copy-Item -Path (Join-Path $TempDir "BOOTSTRAP.md") -Destination $BootstrapTarget
    Write-Host "  ADDED: BOOTSTRAP.md" -ForegroundColor Green
    $CopiedCount++
}

# --- cleanup ---
Remove-Item -Path $TempDir -Recurse -Force

# --- summary ---
Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Files added/overwritten: $CopiedCount"
Write-Host "  Conflicts skipped:       $ConflictCount"
Write-Host ""
Write-Host "Next step:" -ForegroundColor Cyan
Write-Host "  1. Open this folder in VS Code:  code ."
Write-Host "  2. Open Copilot Chat -> Agent Mode -> select Claude Sonnet 4.6"
if ($IsBrownfield) {
    Write-Host "  3. Prompt: 'Execute BOOTSTRAP.md. This is an existing project -- detect what is already here and merge non-destructively.'"
    if ($ConflictCount -gt 0) {
        Write-Host "  NOTE: $ConflictCount file(s) had conflicts and were skipped. BOOTSTRAP.md will ask about each one when it runs." -ForegroundColor Yellow
    }
} else {
    Write-Host "  3. Prompt: 'Execute BOOTSTRAP.md. This is a new project.'"
}
