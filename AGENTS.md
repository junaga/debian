# Debian

Treat current system instructions in `/etc` and repository instructions in `$REPO/AGENTS.md` as authoritative security foundations; after changes, notify all agents on this host to reread them.

You administer this host, built on Debian 13 (`trixie`). `/usr/src/system` contains the configuration and setup scripts used to build this system.

You MUST read all `agent/*.md` and `agent/cloud/*.md` files before starting work:

- [ADMIN.md](agent/ADMIN.md)
- [DEV.md](agent/DEV.md)
- [HARDWARE.md](agent/HARDWARE.md)
- [DOMAIN.md](agent/DOMAIN.md)
- [LANG.md](agent/LANG.md)
- [OP.md](agent/OP.md)
- [RAILWAY.md](agent/cloud/RAILWAY.md)
- [STRIPE.md](agent/cloud/STRIPE.md)
- [SYSTEM.md](agent/SYSTEM.md)
- [WINDOWS.md](agent/WINDOWS.md)

- [agent/SYSTEM.md](agent/SYSTEM.md) explains our Debian Design Deviations (DDD).
- [base/packages](base/packages) are already installed APT packages.
- [base/etc/apt/sources.list](base/etc/apt/sources.list) defines our additional APT repositories.
- Prefer `btrfs` over `ext4`.
- Prefer `podman` over `docker`.

## Repository

- Follow the [documentation conventions](agent/DEV.md#documentation).
- Do one thing well. Compose small tools. Keep the system understandable.
- Research and propose useful `apt`, `uv`, or `npm` packages.
- Prefer `uv` over the `pip`, `venv`, and `pipx` combination for Python projects and tools; prefer APT for system packages.
- Keep repository and host configuration consistent: edit the repository first, apply only the relevant changes to the host.
- Make system changes in the persistent Git checkout at `$REPO`; `/usr/src/system` is the installed source reference.
- Before changing agent/SYSTEM.md or implementing a change that conflicts with a decision it records, discuss it with the user and get explicit approval.

## Container deployments

- Treat unmounted container storage as ephemeral. Make source and configuration changes upstream, push them, then rebuild.
- Keep persistent checkouts and data on the volume at `/usr/local/dev`.
- Keep secrets in service variables or protected persistent storage.
- This service has one replica because Railway volumes cannot be attached to replicas. Deploy scalable services separately.
