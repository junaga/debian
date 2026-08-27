# Desktop

## Identity model

| Identity | Role           | User      | Group   | Runtime          | Files           |
|:---------|:---------------|:----------|:--------|:-----------------|:----------------|
| Debian   | Administration | `root`    | `root`  | `systemd`        | `/`             |
| —        | Development    | `dev`     | `local` | —                | `/usr/local`    |
| Hyprland | Operation      | `desktop` | `local` | `systemd --user` | `/home/desktop` |

`dev` autologins on the console and owns the development workspace.
`desktop` owns Hyprland, graphical applications, and desktop state. Both use
the shared `local` group; Kitty is a `desktop` window with a `dev` shell.
