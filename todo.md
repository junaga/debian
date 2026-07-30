# Todo

- Create and publish a community database mapping Linux applications and
  window roles to Wayland app IDs, X11 classes, titles, tags, and other useful
  metadata; publish this repository with it.
- Implement [tape edge navigation](desktop/tape-navigation.md): reveal a subtle
  arrow over each visible clipped-window fragment and focus that exact window
  when the fragment is clicked.
- Enable persistent final-shutdown logging with a kernel built with
  `CONFIG_PSTORE_CONSOLE`, plus the pstore kernel parameters needed to capture
  hangs after journald has stopped.
