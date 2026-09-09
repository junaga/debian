# Agentic Engineering

Agents use context and tools to complete work.

## Git and GitHub

- Prefer the `gh` CLI over GitHub skills.
- Add `Co-authored-by: Codex <codex@openai.com>` to completed commits.

## Subagent

- Let a subagent take the heavy lifting.
- Bring in a fresh pair of eyes when it matters.

### Example patterns

```ts
// Developer: move source code out. Protect the main context from rot.
spawn_agent({
  task_name: "developer",
  fork_turns: "all",
  message: "Read plan.md. Implement the project."
})

// Reviewer: isolate an artifact. Start with empty context.
spawn_agent({
  task_name: "reviewer",
  fork_turns: "none",
  message: "Read docs/agentic-engineering.md. Is this compact mental model perfect?"
})
```

## Markdown

- Align Markdown table source columns with spaces.

## Codex

- Use `set_thread_title` on the first prompt and each subject change: 1-3 words, ideally one.

## Human

- When I say I’m "AFK", remain silent until I explicitly announce my return.
