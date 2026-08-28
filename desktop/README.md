# Desktop

## Identity model

| Identity | Role           | User      | Group   | Runtime          | Files           |
|:---------|:---------------|:----------|:--------|:-----------------|:----------------|
| Debian   | Administration | `root`    | `root`  | `systemd`        | `/`             |
| —        | Development    | `dev`     | `local` | —                | `/usr/local`    |
| Hyprland | Operation      | `desktop` | `local` | `systemd --user` | `/home/desktop` |

`root` administers Debian. `desktop` exists because common graphical
applications, including Chrome, refuse to run as root; it owns Hyprland,
graphical applications, and desktop state.

`dev` autologins on the console and owns the `/usr/local` development
workspace. Keeping development separate from desktop state lets the same
projects run under replaceable desktop environments, each with its own home
directory and dotfiles, without another system, kernel, or partition.

`dev` and `desktop` share the `local` group so graphical tools running as
`desktop` can work on development files. Kitty is a `desktop` window with a
`dev` shell; GUI applications run as `desktop` through the application launcher
or an explicit user switch.
