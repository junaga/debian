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

## Container deployments

- Treat the container filesystem as ephemeral. A restart, rebuild, redeploy, or new instance can discard runtime changes outside mounted storage.
- Default `REPO` to `/usr/local/src`. The image builds this repository there. Make package, system configuration, startup, and agent instruction changes in the upstream Git repository, then build and deploy a new image. A runtime `apt`, `npm`, or config edit is only a temporary experiment.
- Railway's source archive omits `.git` from `$REPO`. Use the image files as a reference; for source edits, use a temporary Git checkout in `/usr/local/dev` or edit upstream directly. Push changes before rebuilding.
- Keep the shared package and configuration definitions in `instpkg.sh`, `packages`, and `base/`; keep the Dockerfile thin. A fresh image must boot without manual setup on the old instance.
- Use `/usr/local/dev` for persistent projects and working data. Mount the Railway volume there. Keep `/usr/local/src` out of the volume so the image supplies the repository on every deployment.
- Keep secrets out of Git. Use service variables or protected persistent storage for credentials that must survive a redeploy.
- This Railway dev service has one replica because Railway volumes cannot be attached to replicated services. Deploy scalable services separately with shared external storage when needed.

## Workspace

- Read `$HOME/.env` if present, filling only unset variables.
- Default `WORK` to `$HOME`.
- Read `$WORK/AGENTS.md`.
