# Todo

- Create and publish a community database mapping Linux applications and
  window roles to Wayland app IDs, X11 classes, titles, tags, and other useful
  metadata; publish this repository with it.
- Improve Hyprland's scrolling mouse behavior upstream: let a click reach a
  partially visible window before fitting its column, and add column-only drag
  reordering or edge continuation indicators if mouse navigation becomes
  useful.
- Enable persistent final-shutdown logging with a kernel built with
  `CONFIG_PSTORE_CONSOLE`, plus the pstore kernel parameters needed to capture
  hangs after journald has stopped.
