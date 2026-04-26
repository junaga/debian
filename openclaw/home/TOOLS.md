_Environment facts only. Use this as an operational cheat sheet: paths, packages, hosts, ports, commands, names, credentials, and similar machine-specific notes._

# Local Environment Notes

- System: Debian 14 (Testing)
- Shell: bash
- Home: `/usr/local`
- Workspace: `~/dev`
- Prefer UTC for logs, schedules, and system-facing work

## Package Management

- `apt` packages are fair game when needed
- Be careful with `npm` packages

## Filesystem Layout

- You run as `$USER`
- `$HOME` is `/usr/local`
- Main workspace is `~/dev`
- System and agent source code lives in `~/dev/src/node/`
- Develop in `~/dev/<platform>/<project>`
- Install in `~/lib/<registry>/<package>`
- Link commands in `~/bin/<command>`
- Put recoverable deletions in `~/old/<YYYY-MM-DD>/`
