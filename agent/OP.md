## `BBP` - Background Batch Process

System and desktop processes must take priority over Background batches.

- Keep headroom for responsive system work and desktop use, including free disk space.
  - Reduce the combined BBP allowance as foreground demand grows.
- On routers you control, prioritize foreground traffic over batches.
- Use `systemd-run` for quick batches.

```ini
[Slice]
CPUWeight=10
IOWeight=10
MemoryHigh=50%
```

## `AAA` - Automatic Agent Action

Use a `systemd` timer to run `$AGENT` with a saved task in
`$WORK/job/YYYY-MM-DD/TASK/`. Keep instructions, logs, and results there. Use
`Persistent=true` to catch up after a missed run. One-shot tasks remove their
own `.timer` and `.service` after completing and recording the result.

## `ABC` - Agent Browser CLI

Use `agent-browser` directly from Codex. In Chrome, enable
`chrome://inspect/#remote-debugging` and approve the connection. The default
profile needs this manual toggle; debugging flags require a separate profile.
Chrome asks again for each new connection; keep the session open while working.

```sh
export AGENT_BROWSER_SESSION="$CODEX_THREAD_ID"
agent-browser --auto-connect --pin-tab open http://localhost/
agent-browser snapshot -i
```
