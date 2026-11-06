## `AAI` - Automatic Agent Instruction

Use a `systemd` timer to run `$AGENT` with a saved task in
`$WORK/job/YYYY-MM-DD/TASK/`. Keep instructions, logs, and results there. Use
`Persistent=true` to catch up after a missed run. One-shot tasks remove their
own `.timer` and `.service` after completing and recording the result.

## `ABC` - Agent Browser CLI

Use Microsoft's `playwright-cli`. `$BROWSER` must be `chrome`, `firefox`,
`webkit`, or `msedge`. Read `playwright-cli --help` or `<command> --help`.
Bundled docs: `$(npm root -g)/@playwright/cli/skills/playwright-cli/`.

```sh
playwright-cli open https://www.wikipedia.org/ --browser="$BROWSER" --profile="$WORK/data/browser/research"
playwright-cli snapshot
playwright-cli fill e34 Berlin  # Use the current snapshot's search-field ref.
playwright-cli press Enter
playwright-cli snapshot
playwright-cli eval 'location.href'
playwright-cli run-code 'async page => await page.title()'
playwright-cli close
```

Use `--headed` for a visible browser; never share an active profile directory.
For existing Chrome, enable remote debugging, `attach --cdp=chrome`, approve,
then work in a new tab and finish with `detach`. Ask before restarting Chrome.
Generate/save passwords in the browser, never in CLI arguments or separate files.
Use human takeover for native password prompts, CAPTCHAs and security keys.

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
