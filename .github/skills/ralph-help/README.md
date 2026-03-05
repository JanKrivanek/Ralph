# ralph-help

> Sourced and adapted from [anthropics/claude-code – plugins/ralph-wiggum](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum).

This skill provides an overview of the **Ralph Wiggum technique** — an iterative development methodology where the same prompt is fed to Claude repeatedly in a loop, allowing it to see and build upon its own previous work.

## What it does

When invoked, this skill explains:

- **The Ralph Wiggum technique** — how the self-referential loop works and why it's useful.
- **Available commands** — `/ralph-loop` to start a loop, `/cancel-ralph` to stop one.
- **Key concepts** — completion promises, max iterations, and the self-reference mechanism.
- **When to use (and not use) Ralph** — guidance on appropriate tasks.

## Usage

```
/ralph-help
```

No arguments needed. The skill outputs inline help directly to the user without invoking the model.

## Sample loop invocation

```
/ralph-loop "Fix the token refresh logic in auth.ts. Write 'FIXED' to COMPLETED.md when all tests pass." --completion-promise "FIXED" --max-iterations 10
```

The loop runs until Claude writes the promise text (`FIXED`) into `COMPLETED.md`, or the iteration limit is reached — whichever comes first.
