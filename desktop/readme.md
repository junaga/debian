# Desktop

## NVIDIA GPU, [hypr.land](https://hypr.land) and Google Chrome

Run these commands from the repository root.

```sh
bash ./base/upgrade.sh
cp -ra ./base/home/. /root/.

bash ./desktop/format.sh
bash ./desktop/install.sh hypr

reboot 0
```

```sh
# From the root VT:
exec desktop
```

## Recover a stuck desktop

Magic SysRq is handled by the kernel, so it can recover the keyboard even when
Hyprland no longer processes input. On the broken desktop VT, press
`Alt+Print Screen+R` to return the keyboard to console mode, then press
`Alt+Print Screen+K` to kill every process on that VT. The desktop launcher
then exits and the root autologin returns on tty1.

`Print Screen` is the `SysRq` key. Release the keys between combinations. The
`K` operation intentionally terminates the entire graphical session.

![Hyprland Desktop Screenshot](./hypr.webp)
