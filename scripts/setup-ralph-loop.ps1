# Ralph Loop Setup Script
# Creates state file for in-session Ralph loop

param(
    [switch]$Help,
    [int]$MaxIterations = 0,
    [string]$CompletionPromise = "null",
    [Parameter(ValueFromRemainingArguments)]
    [string[]]$PromptParts
)

$ErrorActionPreference = "Stop"

if ($Help) {
    @"
Ralph Loop - Interactive self-referential development loop

USAGE:
  /ralph-loop [PROMPT...] [OPTIONS]

ARGUMENTS:
  PROMPT...    Initial prompt to start the loop (can be multiple words without quotes)

OPTIONS:
  --max-iterations <n>           Maximum iterations before auto-stop (default: unlimited)
  --completion-promise '<text>'  Promise phrase (USE QUOTES for multi-word)
  -h, --help                     Show this help message

DESCRIPTION:
  Starts a Ralph Wiggum loop in your CURRENT session. The stop hook prevents
  exit and feeds your output back as input until completion or iteration limit.

  To signal completion, create COMPLETED.md with your promise phrase.

  Use this for:
  - Interactive iteration where you want to see progress
  - Tasks requiring self-correction and refinement
  - Learning how Ralph works

EXAMPLES:
  /ralph-loop Build a todo API --completion-promise 'DONE' --max-iterations 20
  /ralph-loop --max-iterations 10 Fix the auth bug
  /ralph-loop Refactor cache layer  (runs forever)
  /ralph-loop --completion-promise 'TASK COMPLETE' Create a REST API

STOPPING:
  Only by reaching --max-iterations or detecting --completion-promise
  No manual stop - Ralph runs infinitely by default!

MONITORING:
  # View current iteration:
  Select-String '^iteration:' .claude/ralph-loop.local.md

  # View full state:
  Get-Content .claude/ralph-loop.local.md -TotalCount 10
"@
    exit 0
}

# Join prompt parts
$Prompt = if ($PromptParts) { $PromptParts -join " " } else { "" }

# Validate prompt is non-empty
if ([string]::IsNullOrWhiteSpace($Prompt)) {
    Write-Error @"
No prompt provided

   Ralph needs a task description to work on.

   Examples:
     /ralph-loop Build a REST API for todos
     /ralph-loop Fix the auth bug --max-iterations 20
     /ralph-loop --completion-promise 'DONE' Refactor code

   For all options: /ralph-loop --help
"@
    exit 1
}

# Create state file directory
if (-not (Test-Path ".claude")) {
    New-Item -ItemType Directory -Path ".claude" -Force | Out-Null
}

# Format completion promise for YAML
$CompletionPromiseYaml = if ($CompletionPromise -ne "null" -and -not [string]::IsNullOrEmpty($CompletionPromise)) {
    "`"$CompletionPromise`""
} else {
    "null"
}

# Generate UTC timestamp
$StartedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

# Write state file
$StateContent = @"
---
active: true
iteration: 1
max_iterations: $MaxIterations
completion_promise: $CompletionPromiseYaml
started_at: "$StartedAt"
---

$Prompt
"@

Set-Content -Path ".claude/ralph-loop.local.md" -Value $StateContent -NoNewline

# Output setup message
$MaxIterDisplay = if ($MaxIterations -gt 0) { $MaxIterations } else { "unlimited" }
$PromiseDisplay = if ($CompletionPromise -ne "null") { "$CompletionPromise (ONLY output when TRUE - do not lie!)" } else { "none (runs forever)" }

@"

Ralph loop activated in this session!

Iteration: 1
Max iterations: $MaxIterDisplay
Completion promise: $PromiseDisplay

The stop hook is now active. When you try to exit, the SAME PROMPT will be
fed back to you. You'll see your previous work in files, creating a
self-referential loop where you iteratively improve on the same task.

To monitor: Get-Content .claude/ralph-loop.local.md -TotalCount 10

WARNING: This loop cannot be stopped manually! It will run infinitely
    unless you set --max-iterations or --completion-promise.

"@
