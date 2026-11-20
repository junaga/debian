## `SSR` - System Source Repository

Use `$REPO` as the source for the configuration, package lists, and setup
scripts needed to reproduce this Debian system. `$REPO` defaults to
`/usr/local/src` in [`base/etc/environment`](../base/etc/environment).

Record every persistent system change in `$REPO`. Obtain explicit instructor
approval for every `$REPO` change.

### Design principles

- Express instructions as reusable principles and abstractions that apply across projects and operations.
- Prefer small changes to Debian's defaults.
- Follow each tool's documented setup recommendations and defaults.
- Judge configuration effort. Let Debian handle the underlying implementation.
- Enable persistent diagnostic logging for every component.
- Check what the package manager pulls in. Document only packages that need to
  be selected explicitly.

## `DHC` - Desktop Health Check

At desktop login, run one read-only check for failed system or user services,
recent desktop incidents, and package updates that need operator action.
Use `systemctl --user --failed` and `systemctl --failed`. Follow SIR's
journal access rules. If the evidence indicates an incident, continue with
SIR and obtain instructor approval before making changes.

Check APT candidates with `LC_ALL=C apt list --upgradable`. Compare package
names against the `Package:` patterns in
[`automatic-upgrade.pref`](../base/etc/apt/automatic-upgrade.pref) to identify
updates deferred by the scheduled updater. Report the installed and candidate
versions for those packages. Skip same-version reinstallations. Use the
existing APT indexes and check for `APT indexes refreshed` in the latest
`system-upgrade` run before calling the results current. If the refresh
failed or its freshness cannot be established, report that limitation.

Surface actionable findings to the logged-in operator with `notify-send`
and write the details to the journal. When there is no action to take, log
the result without sending a desktop notification.

## `SIR` - System Incident Resolution

To investigate a system incident, read the logged-in account's journal with
`journalctl --user`. If the account has `sudo` access, also read the non-kernel
entries in the system journal. Obtain instructor approval before reading kernel
logs or opening kernel dumps. Report new kernel dumps to the instructor.

Use component logs, `sar`, and application core dumps owned by that account as
needed. Keep account-specific diagnostics and actions within the logged-in
account.

Establish what failed, when, and under which user. Compare repository settings
with what is installed and running. Capture available evidence before
restarting a frozen component.

Consult the relevant documentation, identify the cause, fix it, and verify the
result. Report the outcome or any blocker to the instructor.

## `RAI` - Respawn Agent Invocation

If you initiate a host reboot or an OS reinstall, you may resume your own thread
at the next boot. The boot hook runs `respawn.sh` from root’s home directory.
For a reinstall, preserve both the script and your thread state.

**Codex example**

```sh
rm -- "$0" || exit 1
USER='<your-unix-user>'
THREAD='<your-current-thread-id>'

exec runuser --login "$USER" --shell /bin/sh <<SH
set -e
codex app-server daemon start
codex queue --thread "$THREAD" --message "Continue..." --resume
SH
```

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
