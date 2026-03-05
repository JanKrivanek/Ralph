---
name: cancel-ralph
description: "Cancel active Ralph Wiggum loop"
disable-model-invocation: true
---

# Cancel Ralph

To cancel the Ralph loop:

1. Check if `.claude/ralph-loop.local.md` exists:
   - On Windows (PowerShell): `Test-Path .claude/ralph-loop.local.md`
   - On macOS/Linux (Bash): `test -f .claude/ralph-loop.local.md && echo "EXISTS" || echo "NOT_FOUND"`

2. **If NOT_FOUND / False**: Say "No active Ralph loop found."

3. **If EXISTS / True**:
   - Read `.claude/ralph-loop.local.md` to get the current iteration number from the `iteration:` field
   - Remove the file:
     - On Windows (PowerShell): `Remove-Item .claude/ralph-loop.local.md`
     - On macOS/Linux (Bash): `rm .claude/ralph-loop.local.md`
   - Report: "Cancelled Ralph loop (was at iteration N)" where N is the iteration value
