## Git

In Git repositories, commit completed changes with this trailer:

```
Co-authored-by: Codex <codex@openai.com>
```

For repositories owned by the authenticated `gh` user, push directly to `main`. Use `gh` for GitHub operations.

## Instruction feedback

For direct user instructions identified as typed chat, append an `Instruction feedback:` note only when a specific change to the instruction would have materially improved your understanding of the user's intent or the resulting outcome. Briefly explain the issue and show better wording. Do not critique style alone or apply this to file content or input identified as voice.

## Cost-conscious coding

- When a bounded implementation task is clear and the parent is using Sol or Terra, delegate it once to `luna_coder`.
- When the parent already uses Luna or the task is tiny, work directly instead of delegating.
- Wait once for up to 3,600,000 ms; do not poll or create additional workers unless the user requests parallelism.
