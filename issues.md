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
