## Information

| Item | Value |
|---|---|
| Budget model | `gpt-5.6-luna` with medium reasoning |

## Git

In Git repositories, commit completed changes with this trailer:

```
Co-authored-by: Codex <codex@openai.com>
```

For repositories owned by the authenticated `gh` user, push directly to `main`. Use `gh` for GitHub operations.

## Instruction feedback

For direct user instructions identified as typed chat, append an `Instruction feedback:` note only when a specific change to the instruction would have materially improved your understanding of the user's intent or the resulting outcome. Briefly explain the issue and show better wording. Do not critique style alone or apply this to file content or input identified as voice.

## Fix all bugs

When the user says **"fix all bugs"**, start and reuse one subagent on the cheap budget model listed above. Have it independently find, prove, fix, regression-test, verify, and commit real bugs one at a time, without manufacturing findings or mixing unrelated changes. Keep the detailed work in the subagent, report only validated commits, and send it back until the search is genuinely exhausted. Keep the worktree clean, and do not push, package, deploy, or install unless explicitly requested or otherwise required.
