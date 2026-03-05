# Ralph Wiggum Stop Hook
# Prevents session exit when a ralph-loop is active
# Feeds Claude's output back as input to continue the loop

$ErrorActionPreference = "Stop"

$RalphStateFile = ".claude/ralph-loop.local.md"
$CompletedFile = "COMPLETED.md"

if (-not (Test-Path $RalphStateFile)) {
    # No active loop - clean up any stale COMPLETED.md and allow exit
    if (Test-Path $CompletedFile) {
        Remove-Item $CompletedFile
    }
    exit 0
}

# Read state file and parse YAML frontmatter
$Content = Get-Content $RalphStateFile -Raw
$FrontmatterMatch = [regex]::Match($Content, '(?s)^---\r?\n(.+?)\r?\n---')
if (-not $FrontmatterMatch.Success) {
    Write-Warning "Ralph loop: State file corrupted - no valid frontmatter"
    Remove-Item $RalphStateFile
    exit 0
}

$Frontmatter = $FrontmatterMatch.Groups[1].Value

# Extract fields from frontmatter
function Get-FrontmatterValue($key) {
    $match = [regex]::Match($Frontmatter, "(?m)^${key}:\s*(.+)$")
    if ($match.Success) { return $match.Groups[1].Value.Trim() }
    return $null
}

$Iteration = Get-FrontmatterValue "iteration"
$MaxIterations = Get-FrontmatterValue "max_iterations"
$CompletionPromise = Get-FrontmatterValue "completion_promise"

# Strip surrounding quotes from completion_promise
if ($CompletionPromise -match '^"(.*)"$') {
    $CompletionPromise = $Matches[1]
}

# Validate numeric fields
if ($Iteration -notmatch '^\d+$') {
    Write-Warning @"
Ralph loop: State file corrupted
   File: $RalphStateFile
   Problem: 'iteration' field is not a valid number (got: '$Iteration')

   This usually means the state file was manually edited or corrupted.
   Ralph loop is stopping. Run /ralph-loop again to start fresh.
"@
    Remove-Item $RalphStateFile
    exit 0
}

if ($MaxIterations -notmatch '^\d+$') {
    Write-Warning @"
Ralph loop: State file corrupted
   File: $RalphStateFile
   Problem: 'max_iterations' field is not a valid number (got: '$MaxIterations')

   This usually means the state file was manually edited or corrupted.
   Ralph loop is stopping. Run /ralph-loop again to start fresh.
"@
    Remove-Item $RalphStateFile
    exit 0
}

$IterationInt = [int]$Iteration
$MaxIterationsInt = [int]$MaxIterations

# Check if max iterations reached
if ($MaxIterationsInt -gt 0 -and $IterationInt -ge $MaxIterationsInt) {
    Write-Output "Ralph loop: Max iterations ($MaxIterationsInt) reached."
    Remove-Item $RalphStateFile
    exit 0
}

# Check for completion promise
if ($CompletionPromise -ne "null" -and -not [string]::IsNullOrEmpty($CompletionPromise)) {
    if (Test-Path $CompletedFile) {
        $CompletedText = (Get-Content $CompletedFile -Raw).Trim() -replace '\s+', ' '
        if ($CompletedText -eq $CompletionPromise) {
            Write-Output "Ralph loop: Detected COMPLETED.md with matching content: $CompletionPromise"
            Remove-Item $RalphStateFile
            Remove-Item $CompletedFile
            exit 0
        }
    }
}

# Not complete - continue loop with SAME PROMPT
$NextIteration = $IterationInt + 1

# Extract prompt text (everything after the closing ---)
$PromptMatch = [regex]::Match($Content, '(?s)^---\r?\n.+?\r?\n---\r?\n(.+)$')
$PromptText = if ($PromptMatch.Success) { $PromptMatch.Groups[1].Value.Trim() } else { "" }

if ([string]::IsNullOrWhiteSpace($PromptText)) {
    Write-Warning @"
Ralph loop: State file corrupted or incomplete
   File: $RalphStateFile
   Problem: No prompt text found

   This usually means:
     - State file was manually edited
     - File was corrupted during writing

   Ralph loop is stopping. Run /ralph-loop again to start fresh.
"@
    Remove-Item $RalphStateFile
    exit 0
}

# Update iteration in state file
$UpdatedContent = $Content -replace '(?m)^iteration:\s*\d+', "iteration: $NextIteration"
Set-Content -Path $RalphStateFile -Value $UpdatedContent -NoNewline

# Build system message
$SystemMsg = if ($CompletionPromise -ne "null" -and -not [string]::IsNullOrEmpty($CompletionPromise)) {
    "Ralph iteration $NextIteration | To stop: write '$CompletionPromise' to COMPLETED.md (ONLY when TRUE - do not lie!)"
} else {
    "Ralph iteration $NextIteration | No completion promise set - loop runs infinitely"
}

# Output JSON to block the stop and feed prompt back
$Output = @{
    decision = "block"
    reason = $PromptText
    systemMessage = $SystemMsg
} | ConvertTo-Json -Compress

Write-Output $Output
exit 0
