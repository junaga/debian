# Desktop

## Identity model

| User model | Role           | User   | Group  | Runtime          | Files        |
| :---------- | :------------- | :----- | :----- | :--------------- | :----------- |
| Debian      | Administration | `root` | `root` | `systemd`        | `/`          |
| —           | Development    | `junaga` | `dev`  | —                | `/usr/local` |
| Hyprland    | Operation      | `hypr`   | `dev`  | `systemd --user` | `/home/hypr` |

`root` administers Debian. `hypr` exists because common graphical
applications, including Chrome, refuse to run as root; it owns Hyprland
and graphical applications in every aspect.

`junaga` autologins on the console and owns the `/usr/local` development
workspace; the login script runs as its intended user. Keeping development
separate from desktop lets the same
system run different desktop environments, each with its own home
directory and dotfiles, without another system, kernel, or partition.

`junaga` and `hypr` share the `dev` group so graphical tools running as `hypr`
can work on development files. A terminal emulator is a `hypr` window with a
`junaga` shell; that user switch is automatic and always occurs. GUI
applications run as `hypr` through the application launcher.

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
