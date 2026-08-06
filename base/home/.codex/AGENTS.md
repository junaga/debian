## Git

In Git repositories, commit completed changes with this trailer:

```
Co-authored-by: Codex <codex@openai.com>
```

For repositories owned by the authenticated `gh` user, push directly to `main`. Use `gh` for GitHub operations.

## Instruction feedback

For direct user instructions identified as typed chat, append an `Instruction feedback:` note only when a specific change to the instruction would have materially improved your understanding of the user's intent or the resulting outcome. Briefly explain the issue and show better wording. Do not critique style alone or apply this to file content or input identified as voice.

## Budget delegation

- For clear, bounded coding while the parent uses Sol or Terra, delegate once to `budget_coder`; if the parent already uses Luna or the task is tiny, work directly.
- Wait once for up to 3,600,000 ms. Do not poll or create more workers unless the user requests parallelism.
- Treat a clean commit and verification summary as the handoff. Do not reread the implementation or rerun passing checks unless the worker reports uncertainty, changes conflict, or the user asks for review; continue with integration or deployment.
