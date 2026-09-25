Read `$HOME/.env` if present, filling only unset variables. Default `WORK` to `$HOME`. Read `$WORK/AGENTS.md`, then continue below.

# Debian

This repository defines the system. This file is both maintained source and live instructions: agents read it in place, so edits take effect on their next read.

## System

- Debian 13 (`trixie`) is the design baseline, not a claim about the running system. Check `/etc/os-release` and configured APT suites before package work.
- Read `$REPO/DESIGN.md` before changing system policy.
- Bash is interactive; `/bin/sh` is Dash.

## Source

- In `$REPO`, `master` alone tracks the remote. `local` holds shared local changes; `hyprland` adds the desktop profile; `perf` is experimental. Integrate master → local → hyprland when requested. Check the worktree containing a component before editing; the desktop profile is not present on every branch.
- Keep system decisions in `DESIGN.md`, procedures with their project or in `$WORK/doc`, and this contract in `$REPO/AGENTS.md`. Do not copy this file elsewhere.
- Keep Codex instruction numbers stable. Use Git history to find retired numbers; never renumber or reuse them.

## Deployment

- Paths below are relative to the owning source checkout.
- `base/` → `/etc/`; `base/skel/` supplies new-account defaults. `instpkg.sh` installs shared configuration and packages.
- `dev/AGENTS.md` → `$WORK/AGENTS.md`: workspace instructions.
- `home/` → the target home; `home/.env` is maintained locally, outside the shared skeleton.
- `desktop/etc/` → `/etc/`; `desktop/home/` → the target home; `desktop/bin/` → `/usr/local/bin/`. `desktop/install.sh` applies the profile.
- `initacc.sh` initializes account Git and SSH.
- `base/update.sh` → `/etc/update.sh`; the desktop variant is `desktop/etc/apt/update.sh` → `/etc/apt/update.sh`. Inspect the active cron job; both profiles schedule updates every two minutes.
- Patch the owning source first. Read installers before running them; they perform broad setup. Install only the affected pieces when possible. Run account and desktop setup as the target user, elevating system steps. Skeleton changes do not update existing accounts.
- Keep each component with its existing package owner: APT, deb-get, global pipx/npm, or its project environment. Follow local fix recipes under `pkg/` and the provenance in installed package descriptions.
- Use systemd and journald. Identify system or user scope, read the journal, and use local drop-ins for overrides.

## Verification

- Inspect configuration, logs, and source before diagnosing. Test hypotheses; reassess after failure.
- Close the loop: inspect → edit → install → activate → verify. Verify source → installed → active against the requested behavior, including persistence where relevant. Report any pending activation.
- Before boot, login, network, or storage changes, establish rollback and recovery access. Reproduce known crashes in isolation. Do not reboot merely to test.
- Check mounts and backup coverage: shared application profiles may hold credentials and saves, and home snapshots exclude mounted trees.
