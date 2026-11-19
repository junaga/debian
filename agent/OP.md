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

Use Microsoft's `playwright-cli`. Read `$BROWSER` to select the browser.

Use one session per agent. A sole agent can use the default; concurrent agents
and forks need distinct named sessions (`-s=NAME`) on every command. Separate
running browsers also need separate profile directories.

```sh
playwright-cli open https://www.wikipedia.org/ --profile="$WORK/dev/hello-world-project"
playwright-cli snapshot
playwright-cli fill e53 Berlin  # Use the current snapshot's search-field ref.
playwright-cli press Enter
playwright-cli eval 'location.href'
playwright-cli close
```

Run Playwright scripts with `playwright-cli run-code --filename=script.js`;
the file contains an `async page => { ... }` function.

Use `--headed` for visible control. To control an existing browser, use
`playwright-cli attach` with its supported connection option, work in a new tab,
and finish with `playwright-cli detach`.

If `$BROWSER` prompts to allow remote debugging, confirm it with a desktop input tool such as `wlrctl`.

Read CLI help for commands and configuration. Bundled docs are at
`$(npm root -g)/@playwright/cli/skills/playwright-cli/`.

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

## `ASF` - Agent Scripting Framework

When scripting an application, game, or system, the agent is the operator.
It writes and runs the script, lets it handle the routine work, and waits
for it to finish. For online services, pace requests conservatively within
the service's limits and honor retry delays.

If a run fails, times out, disconnects, or needs another pass, the agent steps
in to investigate and handle any steps that need manual intervention. It returns
to the script as soon as practical, picking up from saved progress when available.
