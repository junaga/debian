## `RSR` - Reproducible System Repository

Use `$REPO` as the source for the configuration, package lists, and setup
scripts needed to reproduce this Debian system. `$REPO` defaults to
`/usr/local/src` in [`base/etc/environment`](../base/etc/environment).

Record every persistent system change in `$REPO`. Obtain explicit instructor
approval for every `$REPO` change.

### Design principles

- Express instructions as reusable principles and abstractions that apply across projects and operations.
- Prefer small changes to Debian's defaults.
- Judge configuration effort. Let Debian handle the underlying implementation.
- Enable persistent diagnostic logging for every component.
- Check what the package manager pulls in. Document only packages that need to
  be selected explicitly.

## Packages and storage

Research and propose useful packages; prefer APT for system packages and `uv`
over `pip`, `venv`, and `pipx` for Python projects and tools.
Prefer `btrfs` over `ext4` and `podman` over `docker`.

[Installed APT packages](../base/packages) and
[additional APT repositories](../base/etc/apt/sources.list) are recorded in `base/`.

## `BDL` - Backup Directory Layout

Keep one copy per volume. Record backup/export dates, scope, and failures in
`AGENTS.md`. Keep credentials private.

```text
BACKUP/
├── AGENTS.md
├── keys/                         # Credentials and recovery codes.
├── data/                         # Account exports: APP/ACCOUNT/.
│   ├── Google/user@example.com/
│   └── Discord/user@example.com/
└── copy/                         # Local copies: VOLUME/.
    ├── home/
    └── work/
```

Use `rsync -aHAXx` without `--delete`; exclude `tmp/`, `dist/`, and
`node_modules/`. Stop and report failures or free space below 20%.
