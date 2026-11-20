## `ASF` - Agent Scripting Framework

When scripting an application, game, or system, the agent is the operator.
Use a reliable native or automation CLI, or report the failure to the instructor.
Use Bash for shell scripting, `playwright-cli` for browser automation, and
`wlrctl` for Wayland desktop input.

The agent writes and runs the script for routine work, then waits for it to
finish. Use detached `tmux` sessions with logs and checkpoints for long jobs.
For online services, stay within service limits and honor retry delays.

If a run fails or stalls, check the log, handle any manual steps, and resume
from saved progress. Continue until the task is complete or a blocker needs
the instructor.

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
`playwright-cli attach` and work in a dedicated background tab. On restart,
reuse that tab and its scroll position. Detach with `playwright-cli detach`.
If scrolling stalls, try tab-local focus emulation and Playwright wheel input.

If `$BROWSER` prompts to allow remote debugging, confirm it with a desktop input
tool such as `wlrctl`. Coordinate approvals when agents share a browser.

Reuse signed-in browser sessions. For a new sign-in, use the account email
and prefer a passkey over a password when available. Get instructor approval
before signing up for a new account.

[Roon's CAPTCHA example](https://x.com/tszzl/status/2122185311585447958) shows a
separate confirmation after browser-control approval.

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
