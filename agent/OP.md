## `AAI` - Automatic Agent Instruction

Use a `systemd` timer to run `$AGENT` with a saved task in
`$WORK/job/YYYY-MM-DD/TASK/`. Keep instructions, logs, and results there. Use
`Persistent=true` to catch up after a missed run. One-shot tasks remove their
own `.timer` and `.service` after completing and recording the result.

## `ABC` - Agent Browser CLI

Set `$BROWSER` to a Chromium browser. ABC runs it headlessly. List profiles:
ask the instructor if there is more than one; otherwise use `Default`.
Snapshot refs can change.

```sh
export AGENT_BROWSER_SESSION="$CODEX_THREAD_ID"
export AGENT_BROWSER_EXECUTABLE_PATH="${BROWSER:?}"
agent-browser profiles
agent-browser --profile Default open https://www.wikipedia.org/
agent-browser snapshot -i
agent-browser fill @e34 Berlin
agent-browser press Enter
agent-browser snapshot -i
agent-browser get url
agent-browser close
```

For signups or failed headless flows, use `--auto-connect --pin-tab` with the
instructor's running `$BROWSER`. Use a desktop control tool (e.g., `wlrctl`) to
generate passwords in the browser and accept any Save prompt. Never pass
passwords to ABC or store separate copies.
If `--auto-connect` cannot find a browser after remote debugging is enabled,
restart `$BROWSER` and retry.

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
