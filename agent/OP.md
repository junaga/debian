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

Use Microsoft's `playwright-cli`. Read `playwright-cli --help` or
`playwright-cli <command> --help`. Bundled documentation is under
`$(npm root -g)/@playwright/cli/skills/playwright-cli/`.

Use a named session and an explicit persistent profile for headless work.
`--browser` accepts `chrome`, `firefox`, `webkit`, or `msedge`; `$BROWSER` may
instead contain an executable name, so do not pass it without checking.

```sh
playwright-cli -s=research open https://www.wikipedia.org/ --browser=chrome --profile="$WORK/data/browser/research"
playwright-cli -s=research snapshot
playwright-cli -s=research fill e34 Berlin  # Replace e34 with the current search-field ref.
playwright-cli -s=research press Enter
playwright-cli -s=research snapshot
playwright-cli -s=research eval 'location.href'
playwright-cli -s=research run-code 'async page => await page.title()'
playwright-cli -s=research close
```

Snapshot references can change; inspect the current snapshot before acting.
Use `--headed` on `open` for a visible browser. Never share an active profile
directory between browser processes.

For existing Chrome, enable `chrome://inspect/#remote-debugging`, run
`playwright-cli attach --cdp=chrome --session=live`, and approve the connection.
Use `playwright-cli -s=live tab-new` for a dedicated tab, then finish with
`playwright-cli -s=live detach`. Keep the connection open while working.
Ask before restarting personal Chrome if attachment fails.

Generate and save passwords in the browser, never in CLI arguments or separate
files. Use human takeover for native password prompts, CAPTCHAs and security keys.
Persistent profiles contain sensitive session data; keep them private.

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
