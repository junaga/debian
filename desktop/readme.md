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

## NVIDIA GPU, [hypr.land](https://hypr.land) and Google Chrome

Run these commands from the repository root.

```sh
bash ./base/update.sh
cp -ra ./base/home/. /root/.

bash ./desktop/format.sh
bash ./desktop/install.sh hypr

reboot 0
```

```sh
# From the root VT:
desktop
```

## Recover a stuck desktop

Magic SysRq is handled by the kernel, so it can recover the keyboard even when
Hyprland no longer processes input. On the broken desktop VT, press
`Alt+Print Screen+R` to return the keyboard to console mode, then press
`Ctrl+Alt+F1` to reach the root shell. Use `Alt+Print Screen+K` on tty2 only
when the entire graphical session should be terminated.

`Print Screen` is the `SysRq` key. Release the keys between combinations. The
`K` operation intentionally terminates the entire graphical session.

![Hyprland Desktop Screenshot](./hypr.webp)
