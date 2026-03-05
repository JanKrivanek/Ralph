---
name: ralph-loop
description: "Start Ralph Wiggum loop in current session"
argument-hint: "PROMPT [--max-iterations N] [--completion-promise TEXT]"
disable-model-invocation: true
---

# Ralph Loop Command

IMPORTANT, DO NOT SKIP THIS.
The user will give you text after saying "Follow instructions in SKILL.md". Pass that text verbatim as $ARGUMENTS below.

Execute the setup script to initialize the Ralph loop.

On Windows (PowerShell):
```!
powershell -ExecutionPolicy Bypass -File "<workspace_root>/scripts/setup-ralph-loop.ps1" $ARGUMENTS
```

On macOS/Linux (Bash):
```!
"<workspace_root>/scripts/setup-ralph-loop.sh" $ARGUMENTS
```

Please work on the task. When you try to exit, the Ralph loop will feed the SAME PROMPT back to you for the next iteration. You'll see your previous work in files and git history, allowing you to iterate and improve.

CRITICAL RULE: If a completion promise is set, you may ONLY write that exact text to COMPLETED.md when the statement is completely and unequivocally TRUE. Do not write false promises to escape the loop, even if you think you're stuck or should exit for other reasons. The loop is designed to continue until genuine completion.