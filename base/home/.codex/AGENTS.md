## Git

In Git repositories, commit completed changes with this trailer:

```
Co-authored-by: Codex <codex@openai.com>
```

For repositories owned by the authenticated `gh` user, push directly to `main`. Use `gh` for GitHub operations.

## Instruction feedback

For direct user instructions identified as typed chat, append an `Instruction feedback:` note only when a specific change to the instruction would have materially improved your understanding of the user's intent or the resulting outcome. Briefly explain the issue and show better wording. Do not critique style alone or apply this to file content or input identified as voice.

## Fix all bugs

When the user says **"fix all bugs"**, start a persistent bug-hunting loop:

1. Spawn one subagent to independently find concrete, reproducible bugs across the repository, and reuse that same subagent thread for the entire loop.
2. For each confirmed bug, have the subagent make the smallest correct fix, add regression coverage, run the relevant tests, and create a focused commit following the Git instructions above.
3. Require a clean worktree after every commit. Do not manufacture findings or mix unrelated changes.
4. Keep detailed investigation in the subagent. In the main thread, report only each new commit, the bug fixed, and verification, then immediately send the same subagent back to continue.
5. Do not push, package, deploy, or install unless the user explicitly asks or another applicable instruction requires it.
6. Continue until repeated exhaustive passes find no defensible new bug; then report that the search is exhausted.
