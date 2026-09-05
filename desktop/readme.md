# Desktop

## User model

| User | Primary group | UID | Role |
| :-- | :-- | :-- | :-- |
| `root` | `root` | 0 | System administration |
| `local` | `local` | 1000 | Desktop, development, and `/usr/local` workspace |

`local` runs the desktop and development tools because applications such as Google Chrome do not support running as root.
`local` has passwordless sudo and is automatically logged in on Linux virtual terminals, with one home at `/home/local` for both graphical and headless work.

## NVIDIA GPU, [hypr.land](https://hypr.land) and Google Chrome

Run these commands from the repository root.

```sh
bash ./base/update.sh
cp -ra ./base/home/. /root/.

bash ./desktop/format.sh
bash ./desktop/install.sh

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
