<#
.SYNOPSIS
  Verify a project bootstrapped with the SDLC Bootstrap Kit. Stage-aware: runs only the checks relevant to the phase you just completed.

.DESCRIPTION
  Designed to be invoked by Copilot Agent Mode automatically after each phase in BOOTSTRAP.md. Each -Stage runs a focused subset of invariants. FAIL exit code halts the bootstrap so Copilot stops and reports instead of proceeding on broken state.

  Stages, ordered by when BOOTSTRAP.md invokes them:
    prereqs            after Phase B  — CLIs installed
    bmad-install       after C.1/D.2  — BMAD v6 installed cleanly
    speckit-install    after C.2/D.3  — Spec Kit installed
    framework-files    after C.3/D.4  — kit's framework files in place
    governance-merge   after C.4      — governance rules merged into BMAD persona skills
    imports            after import   — docs/ has expected requirements files
    constitution       after C.8/D.6  — constitution.md exists, stamped, sane
    atomic-commits     after C.7/D.9  — git log has expected commit chain
    final              after C.9/D.10 — full pre-SDLC-Engine state ready
    pre-coding         after Phase 4  — SDLC Engine ran through ready-for-development gate
    sprint-1           after first PR merge

.PARAMETER Stage
  Which stage's invariants to check. Default: 'final'.

.PARAMETER Json
  Emit JSON instead of human-readable output (for CI).

.EXAMPLE
  pwsh ./scripts/verify-bootstrap.ps1 -Stage bmad-install
  pwsh ./scripts/verify-bootstrap.ps1 -Stage final
  pwsh ./scripts/verify-bootstrap.ps1 -Stage pre-coding -Json
#>
[CmdletBinding()]
param(
    [ValidateSet('prereqs','bmad-install','speckit-install','framework-files',
                 'governance-merge','imports','constitution','atomic-commits',
                 'final','pre-coding','sprint-1')]
    [string]$Stage = 'final',
    [switch]$Json
)

$ErrorActionPreference = 'Continue'
$script:results = New-Object System.Collections.ArrayList
$script:pass = 0
$script:warn = 0
$script:fail = 0

function _Record($Cat, $Name, $Status, $Evidence) {
    [void]$script:results.Add([PSCustomObject]@{
        Category=$Cat; Name=$Name; Status=$Status; Evidence=$Evidence
    })
    switch ($Status) { 'PASS'{$script:pass++}; 'WARN'{$script:warn++}; 'FAIL'{$script:fail++} }
}
function Check($Cat, $Name, $Test, $Evidence='') {
    try {
        $r = & $Test
        $s = if ($r) {'PASS'} else {'FAIL'}
    } catch { $s='FAIL'; $Evidence="Error: $_" }
    _Record $Cat $Name $s $Evidence
    if (-not $Json) {
        $i = switch ($s) {'PASS'{'[+]'} 'FAIL'{'[X]'} 'WARN'{'[!]'}}
        $c = switch ($s) {'PASS'{'Green'} 'FAIL'{'Red'} 'WARN'{'Yellow'}}
        Write-Host ("  {0} {1,-55} {2}" -f $i, $Name, $Evidence) -ForegroundColor $c
    }
}
function CheckWarn($Cat, $Name, $Test, $Evidence='') {
    try {
        $r = & $Test
        $s = if ($r) {'PASS'} else {'WARN'}
    } catch { $s='WARN'; $Evidence="Error: $_" }
    _Record $Cat $Name $s $Evidence
    if (-not $Json) {
        $i = switch ($s) {'PASS'{'[+]'} 'WARN'{'[!]'}}
        $c = switch ($s) {'PASS'{'Green'} 'WARN'{'Yellow'}}
        Write-Host ("  {0} {1,-55} {2}" -f $i, $Name, $Evidence) -ForegroundColor $c
    }
}
function Header($t) { if (-not $Json) { Write-Host ""; Write-Host "=== $t ===" -ForegroundColor Cyan } }

# -----------------------------------------------------------
# Stage-specific check functions
# -----------------------------------------------------------

function CheckStage-Prereqs {
    Header "Prereqs"
    foreach ($cli in @('node','npm','git','gh','claude')) {
        Check 'prereqs' "CLI: $cli" {
            (Get-Command $cli -ErrorAction SilentlyContinue) -ne $null
        } ''
    }
    CheckWarn 'prereqs' 'CLI: uv (preferred for Spec Kit on Windows)' {
        (Get-Command uv -ErrorAction SilentlyContinue) -ne $null
    } 'falls back to pipx if absent'
    CheckWarn 'prereqs' 'CLI: pipx (fallback)' {
        (Get-Command pipx -ErrorAction SilentlyContinue) -ne $null
    } ''
}

function CheckStage-BmadInstall {
    Header "BMAD install"
    Check 'bmad' 'BMAD core (_bmad/core)'   { Test-Path '_bmad/core' } ''
    Check 'bmad' 'BMAD bmm (_bmad/bmm)'     { Test-Path '_bmad/bmm' } ''
    Check 'bmad' 'BMAD config.toml'         { Test-Path '_bmad/config.toml' } ''
    $skillCount = (Get-ChildItem '.agents/skills' -Directory -ErrorAction SilentlyContinue).Count
    Check 'bmad' 'BMAD persona skills (>=7)' { $skillCount -ge 7 } "found $skillCount"
    # Verify the 7 canonical personas exist
    foreach ($p in @('analyst','pm','architect','po','sm','dev','qa')) {
        CheckWarn 'bmad' "  persona skill: bmad-agent-$p" {
            Test-Path ".agents/skills/bmad-agent-$p"
        } ''
    }
}

function CheckStage-SpeckitInstall {
    Header "Spec Kit install"
    Check 'speckit' '.specify/ root'           { Test-Path '.specify' } ''
    Check 'speckit' '.specify/memory/'         { Test-Path '.specify/memory' } ''
    Check 'speckit' 'constitution template'    { Test-Path '.specify/memory/constitution.template.md' } ''
    CheckWarn 'speckit' 'slash commands registered' {
        (Get-ChildItem '.specify' -Recurse -Filter '*.prompt.md' -ErrorAction SilentlyContinue).Count -ge 4
    } 'specify/plan/tasks/implement prompts expected'
}

function CheckStage-FrameworkFiles {
    Header "Kit framework files"
    Check 'kit' 'governance-rules.md'          { Test-Path '.bmad-additions/governance-rules.md' } ''
    Check 'kit' '.github/copilot-instructions.md' { Test-Path '.github/copilot-instructions.md' } ''
    foreach ($a in @('sdlc-engine','security','devops','instruction-refactor','instruction-loop')) {
        Check 'kit' "agent: @$a" { Test-Path ".github/agents/$a.agent.md" } ".github/agents/$a.agent.md"
    }
    foreach ($a in @('sdlc-engine','security','devops','instruction-refactor','instruction-loop')) {
        $p = ".github/agents/$a.agent.md"
        if (Test-Path $p) {
            $head = Get-Content $p -TotalCount 10 -ErrorAction SilentlyContinue
            Check 'kit' "  frontmatter parses: $a" {
                ($head[0] -eq '---') -and (($head -join "`n") -match '(?m)^name:\s*\S')
            } ''
        }
    }
    foreach ($t in @('vision','functional-requirements','non-functional-requirements','adr')) {
        Check 'kit' "template: $t.template.md" { Test-Path "docs/templates/$t.template.md" } ''
    }
}

function CheckStage-GovernanceMerge {
    Header "Governance merge into BMAD persona skills"
    if (-not (Test-Path '.bmad-additions/governance-rules.md')) {
        Check 'governance' 'governance-rules.md present' { $false } 'cannot check merge without source rules'
        return
    }
    # Sample a few persona skill files and look for a governance marker
    $marker = 'Governance Rules'  # what governance-rules.md content gets inserted under
    $sampledPersonas = @('analyst','pm','architect','po','sm','dev','qa')
    $merged = 0
    foreach ($p in $sampledPersonas) {
        $files = Get-ChildItem ".agents/skills/bmad-agent-$p" -Recurse -Filter '*.md' -ErrorAction SilentlyContinue
        foreach ($f in $files) {
            if ((Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue) -match $marker) {
                $merged++
                break
            }
        }
    }
    Check 'governance' "Personas with governance merged (>=5)" { $merged -ge 5 } "found $merged of 7"
}

function CheckStage-Imports {
    Header "Requirements imports"
    $expected = @('VISION','FUNCTIONAL_REQUIREMENTS','NON_FUNCTIONAL_REQUIREMENTS','SCOPE','STAKEHOLDERS',
                  'CONSTRAINTS','ASSUMPTIONS','GLOSSARY','RISKS','OPEN_QUESTIONS','TRACEABILITY',
                  'SITE_FUNCTIONALITY_ALIGNMENT_ADDENDUM')
    foreach ($f in $expected) {
        $doc = "docs/$f.md"
        $orig = "Initial Input/requirements/$f.md"
        if (Test-Path $doc) {
            if (Test-Path $orig) {
                $dl = (Get-Content $doc).Count
                $ol = (Get-Content $orig).Count
                if ($dl -eq $ol) {
                    Check 'imports' "$f.md" { $true } "$dl lines (unchanged)"
                } else {
                    CheckWarn 'imports' "$f.md" { $true } "$dl vs $ol lines (refined)"
                }
            } else {
                Check 'imports' "$f.md" { $true } 'exists (no original)'
            }
        } else {
            Check 'imports' "$f.md" { $false } 'MISSING'
        }
    }
}

function CheckStage-Constitution {
    Header "Constitution"
    Check 'constitution' 'file exists' { Test-Path '.specify/memory/constitution.md' } ''
    if (Test-Path '.specify/memory/constitution.md') {
        $c = Get-Content '.specify/memory/constitution.md' -Raw
        $stamp = ($c | Select-String 'bootstrap_kit_version:\s*\S+' | ForEach-Object {$_.Matches[0].Value})
        Check 'constitution' 'bootstrap_kit_version stamped' {
            $c -match 'bootstrap_kit_version:\s*\S'
        } $stamp
        Check 'constitution' 'project_name set' { $c -match 'project_name:\s*\S' } ''
        $sc = ($c | Select-String -Pattern '^## ' -AllMatches).Matches.Count
        Check 'constitution' 'section count >= 10' { $sc -ge 10 } "$sc sections"
        $lc = (Get-Content '.specify/memory/constitution.md').Count
        Check 'constitution' 'min length >= 100 lines' { $lc -ge 100 } "$lc lines"
    }
}

function CheckStage-AtomicCommits {
    Header "Git commit chain"
    if (-not (Test-Path '.git')) {
        Check 'git' 'repo initialized' { $false } 'no .git/ found'
        return
    }
    $commits = git log --oneline 2>$null
    $cc = ($commits | Measure-Object -Line).Lines
    Check 'git' 'commit count >= 5' { $cc -ge 5 } "found $cc commits"
    foreach ($p in @('install BMAD','install Spec Kit','install SDLC kit framework','import.*artifact','constitution')) {
        $f = $commits | Select-String -Pattern $p -Quiet
        Check 'git' "  commit matching '$p'" { $f } (if ($f){'found'}else{'no match'})
    }
    $status = git status --porcelain 2>$null
    $clean = [string]::IsNullOrWhiteSpace($status)
    Check 'git' 'Working tree clean' { $clean } (
        if ($clean) {'clean'} else {"$(($status -split [Environment]::NewLine).Count) uncommitted"})
}

function CheckStage-InitialInputPreserved {
    Header "Initial Input preserved"
    Check 'preserved' 'Initial Input/ exists' { Test-Path 'Initial Input' } ''
    Check 'preserved' '  requirements/ has >= 12 files' {
        (Get-ChildItem 'Initial Input/requirements' -File -ErrorAction SilentlyContinue).Count -ge 12
    } ''
    Check 'preserved' '  instructions/ has >= 7 files' {
        (Get-ChildItem 'Initial Input/instructions' -File -ErrorAction SilentlyContinue).Count -ge 7
    } ''
    Check 'preserved' '  MASTER_PLAN.md'    { Test-Path 'Initial Input/MASTER_PLAN.md' } ''
    Check 'preserved' '  PROGRESS_TRACKER.md' { Test-Path 'Initial Input/PROGRESS_TRACKER.md' } ''
}

function CheckStage-Readiness-PreCoding {
    Header "Pre-coding readiness (SDLC Engine outputs)"
    foreach ($a in @('c4-context','c4-container','c4-component','runtime-view','deployment-view','data-model')) {
        Check 'readiness' "docs/architecture/$a.md" { Test-Path "docs/architecture/$a.md" } ''
    }
    Check 'readiness' 'docs/architecture/decisions/ (>=1 ADR)' {
        (Get-ChildItem 'docs/architecture/decisions' -File -ErrorAction SilentlyContinue).Count -ge 1
    } ''
    Check 'readiness' 'docs/security/threat-model.md' { Test-Path 'docs/security/threat-model.md' } ''
    Check 'readiness' 'docs/epics/ (>=1)' {
        (Get-ChildItem 'docs/epics' -File -ErrorAction SilentlyContinue | Where-Object Name -ne '.gitkeep').Count -ge 1
    } ''
    Check 'readiness' 'docs/stories/ (>=1)' {
        (Get-ChildItem 'docs/stories' -File -ErrorAction SilentlyContinue | Where-Object Name -ne '.gitkeep').Count -ge 1
    } ''
    Check 'readiness' 'docs/sprints/SPRINT-01.md' { Test-Path 'docs/sprints/SPRINT-01.md' } ''
    CheckWarn 'readiness' '.sdlc-engine-state.md' { Test-Path '.sdlc-engine-state.md' } ''
}

function CheckStage-Readiness-Sprint1 {
    Header "Sprint-1 readiness"
    Check 'readiness' 'src/ has implementation' {
        (Get-ChildItem 'src' -Recurse -File -ErrorAction SilentlyContinue).Count -ge 1
    } ''
    Check 'readiness' '.github/workflows/ci.yml' { Test-Path '.github/workflows/ci.yml' } ''
    Check 'readiness' '.github/workflows/security.yml' { Test-Path '.github/workflows/security.yml' } ''
    $merges = (git log --oneline --merges 2>$null | Measure-Object -Line).Lines
    CheckWarn 'readiness' "merged PRs >= 1" { $merges -ge 1 } "found $merges merge commits"
}

# -----------------------------------------------------------
# Stage dispatcher
# -----------------------------------------------------------

if (-not $Json) {
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "  SDLC Bootstrap Kit Verification" -ForegroundColor Cyan
    Write-Host "  Stage:        $Stage" -ForegroundColor Cyan
    Write-Host "  Repo:         $(Get-Location)" -ForegroundColor Cyan
    Write-Host "  Date:         $(Get-Date -Format 'yyyy-MM-dd HH:mm')" -ForegroundColor Cyan
    Write-Host "================================================================" -ForegroundColor Cyan
}

switch ($Stage) {
    'prereqs'         { CheckStage-Prereqs }
    'bmad-install'    { CheckStage-BmadInstall }
    'speckit-install' { CheckStage-SpeckitInstall }
    'framework-files' { CheckStage-FrameworkFiles }
    'governance-merge'{ CheckStage-GovernanceMerge }
    'imports'         { CheckStage-Imports }
    'constitution'    { CheckStage-Constitution }
    'atomic-commits'  { CheckStage-AtomicCommits }
    'final' {
        CheckStage-BmadInstall
        CheckStage-SpeckitInstall
        CheckStage-FrameworkFiles
        CheckStage-GovernanceMerge
        CheckStage-Imports
        CheckStage-Constitution
        CheckStage-InitialInputPreserved
        CheckStage-AtomicCommits
    }
    'pre-coding' {
        CheckStage-BmadInstall
        CheckStage-FrameworkFiles
        CheckStage-Imports
        CheckStage-Constitution
        CheckStage-InitialInputPreserved
        CheckStage-AtomicCommits
        CheckStage-Readiness-PreCoding
    }
    'sprint-1' {
        CheckStage-Readiness-PreCoding
        CheckStage-Readiness-Sprint1
    }
}

# -----------------------------------------------------------
# Summary
# -----------------------------------------------------------

if ($Json) {
    [PSCustomObject]@{
        stage    = $Stage
        repo     = (Get-Location).Path
        date     = (Get-Date -Format 'o')
        pass     = $script:pass
        warn     = $script:warn
        fail     = $script:fail
        verdict  = if ($script:fail -eq 0) { 'READY' } else { 'NOT READY' }
        results  = $script:results
    } | ConvertTo-Json -Depth 5
} else {
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "  Summary  ($Stage)" -ForegroundColor Cyan
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ("  Pass:  {0}" -f $script:pass) -ForegroundColor Green
    Write-Host ("  Warn:  {0}" -f $script:warn) -ForegroundColor Yellow
    Write-Host ("  Fail:  {0}" -f $script:fail) -ForegroundColor (if ($script:fail -gt 0) {'Red'} else {'Gray'})
    Write-Host ""
    if ($script:fail -eq 0) {
        Write-Host "  VERDICT: READY (stage '$Stage' verified)" -ForegroundColor Green
    } else {
        Write-Host "  VERDICT: NOT READY -- fix FAILs before next phase" -ForegroundColor Red
    }
    Write-Host ""
}

exit ($script:fail -gt 0 ? 1 : 0)
