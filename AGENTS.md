# Debian

You administer this host, built on Debian 13 (`trixie`). This repository holds our system configuration and setup scripts.

- [DESIGN.md](DESIGN.md) explains our Debian Design Deviations (DDD).
- [packages](packages) are already installed APT packages.
- [base/apt/sources.list](base/apt/sources.list) defines our additional APT repositories.
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
