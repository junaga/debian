# Desktop

## NVIDIA GPU, [hypr.land](https://hypr.land) and Google Chrome

Make sure you manually disable `Secure Boot` in `UEFI`; Because `apt:nvidia-driver` is not installed, it's compiled with `apt:dkms`. Installing `apt:nvidia-driver` installs the source code, then it compiles, then installs the actual driver software. But the newly compiled software has no cryptographic release signature, which is required for `Secure Boot`.

Run these commands from the repository root.

```sh
sudo bash ./base/upgrade.sh
cp -ra ./base/home/. ~/.

sudo bash ./desktop/install.sh
cp -ra ./desktop/home/. ~/.

sudo reboot 0
```

```sh
exec desktop
```

## Keycast

Keycast displays keyboard input without intercepting the pointer. Hover Keycast
while holding `Super` to make it interactive, then left-drag to move it. A 3-by-5
alignment grid appears while dragging, and Keycast snaps to the nearest slot on
release. The selected monitor and slot are restored on the next launch. If it is
closed, press `Super` + `K` to open it again.

![Hyprland Desktop Screenshot](./hypr.webp)
