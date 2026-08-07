# Todo

- Create and publish a community database mapping Linux applications and
  window roles to Wayland app IDs, X11 classes, titles, tags, and other useful
  metadata; publish this repository with it.
- Implement [tape edge navigation](desktop/tape-navigation.md): reveal a subtle
  arrow over each visible clipped-window fragment and focus that exact window
  when the fragment is clicked.
- Implement the native [Keycast overlay](desktop/keycast.md).
- Enable persistent final-shutdown logging with a kernel built with
  `CONFIG_PSTORE_CONSOLE`, plus the pstore kernel parameters needed to capture
  hangs after journald has stopped.
- Fix the reboot upgrade job and Codex remote-control daemon lifecycle. The
  `@reboot` entry installed by `base/setup.sh` runs `base/upgrade.sh` as the
  desktop user, although the upgrade script performs privileged package and
  `/etc/apt` operations. Running the script manually with `sudo` caused Codex
  remote control to start as root under `/tmp/.codex`, leaving an errored,
  root-owned daemon disconnected from the desktop user session. Implement a
  privilege-safe boot service with an explicit user phase before restoring
  automatic remote-control startup.
