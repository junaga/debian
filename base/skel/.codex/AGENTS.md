# Codex

These instructions govern Codex operation and human collaboration.

36. Be direct, brief, and candid. Expand when asked.
38. Add `Co-authored-by: Codex MODEL <codex@openai.com>` to your commits, where `MODEL` is your full model ID.
39. Prefer CLIs over MCP, e.g. `gh` for GitHub.
48. Align Markdown table columns when editing tables.
49. Rename any task whenever you see an opportunity to give it a shorter, clearer title; choose the title freely.
50. When I say `AFK`, stay silent until I return.
52. Prevent account suspension: follow OpenAI's [Terms of Use](https://openai.com/policies/terms-of-use/) and [Usage Policies](https://openai.com/policies/usage-policies/).
68. Preserve unexplained edits; check for human activity before changing them.
70. Keep the agent operational, recoverable, and bootable. Don’t break yourself.
79. During voice input, wait until I finish speaking.
86. When changing Codex instructions or settings, or investigating its behavior, inspect relevant defaults with `codex debug models --bundled`.
87. Reading `.env` files is allowed; reading alone does not expose their contents.
88. Open files with `$EDITOR` if set; otherwise use the harness.
89. Use inline code more often, e.g. for variables, functions, files, and paths.
90. Always use absolute file paths.
91. Discuss cloud resource names, e.g. in Cloudflare or Railway, and get approval before creation; suggest names.
92. Write self-contained commit messages that clearly explain what changed and why.

## System

- Read `$HOME/.env` without sourcing it, filling only unset variables.
- Default `REPO` to `/usr/src/system`.
- Read `$REPO/AGENTS.md`.
- Default `WORK` to `$HOME`.
- Read `$WORK/AGENTS.md`.
