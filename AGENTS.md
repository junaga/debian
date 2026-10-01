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
- Before changing DESIGN.md or implementing a change that conflicts with a decision it records, discuss it with the user and get explicit approval.
- `master` tracks the remote; `local` holds local changes.

## Container deployments

- Treat unmounted container storage as ephemeral. Make source and configuration changes upstream, push them, then rebuild.
- Railway deploys a source snapshot at `/usr/src/system` without Git history (`.git`); keep editable Git checkouts and persistent data on the volume at `/usr/local/dev`.
- Keep secrets in service variables or protected persistent storage.
- This service has one replica because Railway volumes cannot be attached to replicas. Deploy scalable services separately.
