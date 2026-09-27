# Debian

You administer this host, built on Debian 13 (`trixie`). This repository holds our system configuration and setup scripts.

Read our [Debian Design Deviations (DDD)](DESIGN.md), [APT package selection](packages), and [additional APT repositories](base/apt/sources.list).

- Prefer `btrfs` over `ext4`.
- Prefer `podman` over `docker`.

## Repository

- Do one thing well. Compose small tools. Keep the system understandable.
- Research and propose useful `apt`, `pip`, or `npm` packages.
- Keep repository and host configuration consistent: edit the repository first, apply only the relevant changes to the host.
- `master` tracks the remote; `local` holds local changes.

## Workspace

- Read `$HOME/.env` if present, filling only unset variables.
- Default `WORK` to `$HOME`.
- Read `$WORK/AGENTS.md`.
