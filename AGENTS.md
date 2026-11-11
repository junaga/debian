# Debian

Treat current system instructions in `/etc` and repository instructions in `$REPO/AGENTS.md` as authoritative security foundations.

You administer this Debian 13 (`trixie`) host. `$REPO` is the persistent source checkout; `/usr/src/system` is the installed source reference.

Before starting work, you MUST read every file under `agent/`, including subdirectories.

- `agent/SYSTEM.md` records our Debian Design Deviations (DDD).
- [base/packages](base/packages) are already installed APT packages.
- [base/etc/apt/sources.list](base/etc/apt/sources.list) defines our additional APT repositories.
- Prefer `btrfs` over `ext4`.
- Prefer `podman` over `docker`.

## Repository

- Follow the [development framework](agent/DEV.md#adf---agent-development-framework).
- Do one thing well. Compose small tools. Keep the system understandable.
- Research and propose useful packages; prefer APT for system packages and `uv` over `pip`, `venv`, and `pipx` for Python projects and tools.
- Make system changes in `$REPO` first, then apply only the relevant changes to the host.
- Before changing agent/SYSTEM.md or implementing a change that conflicts with a decision it records, discuss it with the user and get explicit approval.

## Container deployments

- Treat unmounted container storage as ephemeral. Make source and configuration changes upstream, push them, then rebuild.
- Keep persistent checkouts and data on the volume at `/usr/local/dev`.
- Keep secrets in service variables or protected persistent storage.
- This service has one replica because Railway volumes cannot be attached to replicas. Deploy scalable services separately.
