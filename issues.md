# Issues

## 1. Linux application identity database

Create and publish a community database mapping Linux applications and window
roles to Wayland app IDs, X11 classes, titles, tags, and other useful metadata.

## 2. Tape edge navigation

Implement [tape edge navigation](desktop/tape-navigation.md): reveal a subtle
arrow over each visible clipped-window fragment and focus that exact window
when the fragment is clicked.

## 3. Native Keycast overlay

Implement the native [Keycast overlay](desktop/keycast.md).

## 4. Persistent shutdown-failure logging

Enable persistent final-shutdown logging with a kernel built with
`CONFIG_PSTORE_CONSOLE`, plus the pstore kernel parameters needed to capture
hangs after journald has stopped.

## 5. Privilege-safe boot upgrades and Codex daemon startup

The `@reboot` entry installed by `base/setup.sh` runs `base/upgrade.sh` as the
desktop user, although the upgrade script performs privileged package and
`/etc/apt` operations. Running the script manually with `sudo` caused Codex
remote control to start as root under `/tmp/.codex`, leaving an errored,
root-owned daemon disconnected from the desktop user session.

Implement a privilege-safe boot service with an explicit user phase before
restoring automatic remote-control startup.

## 6. Debian Hyprgraphics ABI-transition crash

Debian testing upgraded `libhyprgraphics4` from `0.5.1-2+b1` to `0.5.1-2+b2`.
The rebuilt library uses `libhyprutils13`, while Hyprland `0.55.4+ds-2+b1`
still uses Hyprutils 12 types at the Hyprgraphics interface. Hyprland then
crashed in image-resource cleanup, and its fallback configuration aborted while
cleaning up a text resource.

The temporary repair downgraded both `libhyprgraphics4` and
`libhyprgraphics-dev` to the official Debian snapshot build `0.5.1-2+b1` and
placed both packages on hold. A 12-second `desktop` smoke test produced no new
crash report.

Report or patch the Debian package transition, then remove the holds only after
a consistently rebuilt package set is available and passes both normal- and
fallback-config startup tests.

## 7. Replace the HOME migration script

Replace `desktop/merge-home.sh` with an explicit, repeatable migration from a
conventional user home to `/usr/local`. The current script recursively changes
ownership of all `/usr/local`, deletes every empty directory below it, copies
HOME without a transactional move or collision checks, and rewrites
`/etc/passwd` using an unrestricted string substitution. It has no preflight,
backup, rollback, interruption recovery, verification, or safe second-run
behavior.

The current machine records `/usr/local` as the account home and exposes the
same directory inode at both `/usr/local` and `/home/junaga`. The replacement
must define whether the conventional path is a bind mount, compatibility link,
or removed entirely; migrate hard-coded `/home/$USER` consumers such as
`desktop/home/bin/install-steam`; and preserve ownership boundaries for
system-managed content under `/usr/local`.

The HOME rename also broke Steam. Valve's Pressure Vessel runtime constructs
its container filesystem from `/usr` and cannot share the Steam installation,
game libraries, or HOME when they live below `/usr/local`. Bypassing Steam's
requirements check was insufficient: `steamwebhelper` entered a restart loop
because the container still could not access those paths. Commit `cb2caca`
introduced the current workaround: `desktop/home/bin/install-steam` bind-mounts
the entire `/usr/local` home at `/home/$USER`, rewrites Steam's data directory
to that alias, and launches Steam with `HOME=/home/$USER`.

That workaround explains why `/usr/local` and `/home/junaga` currently have the
same inode, but it is not a sound account-migration design. It requires an
interactive `sudo mount` during application launch, aliases the entire home
rather than only Steam data, can conceal pre-existing content at the mount
point, persists until unmounted or rebooted, and leaves Steam, Proton, games,
saves, XDG state, and cloud-sync paths dependent on two names for one tree. A
replacement HOME layout must give Pressure Vessel a supported path without an
application launcher mutating the global mount namespace. Preserve and verify
the existing Steam library, Proton prefixes, game saves (including Factorio),
login state, and cloud-sync metadata during migration.

Use account-management and filesystem primitives instead of editing
`/etc/passwd` directly. Design and test preflight, conflict handling, atomic or
resumable data transfer, account update, compatibility-path creation, login and
service restart behavior, rollback, and post-migration verification. Test both
a fresh installation and an already-migrated machine before replacing the
current script. The acceptance test must launch Steam and a Pressure
Vessel/Proton game after a clean reboot without an ad hoc bind mount or path
sharing errors.
