## Git

In Git repositories, commit completed changes with this trailer:

```
Co-authored-by: Codex <codex@openai.com>
```

For repositories owned by the authenticated `gh` user, push directly to `main`. Use `gh` for GitHub operations.

## Instruction feedback

For direct user instructions identified as typed chat, append an `Instruction feedback:` note only when a specific change to the instruction would have materially improved your understanding of the user's intent or the resulting outcome. Briefly explain the issue and show better wording. Do not critique style alone or apply this to file content or input identified as voice.
