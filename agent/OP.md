## `AAI` - Automatic Agent Instruction

Use `cron` to schedule your own tasks or another AI `$AGENT`.

### Respawn

The default `/etc/crontab` entry runs `$HOME/respawn.sh` at boot.
Use it to automatically invoke yourself across system reinstallation, reboot,
or container redeployment by hardcoding the agent command and chat ID in the script.
If `$HOME/respawn.sh` already exists, you MUST NOT overwrite it.

#### Codex example

- `$HOME/respawn.sh`

```sh
rm -- "$HOME/respawn.sh"
THREAD_UUID="01a1b106-e12f-7be0-844f-588482207b23"
/usr/bin/codex app-server daemon start
/usr/bin/codex queue --thread "$THREAD_UUID" --message "Continue..." --resume
```

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
