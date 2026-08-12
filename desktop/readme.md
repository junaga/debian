# Desktop

## NVIDIA GPU, [hypr.land](https://hypr.land) and Google Chrome

Make sure you manually disable `Secure Boot` in `UEFI`; Because `apt:nvidia-driver` is not installed, it's compiled with `apt:dkms`. Installing `apt:nvidia-driver` installs the source code, then it compiles, then installs the actual driver software. But the newly compiled software has no cryptographic release signature, which is required for `Secure Boot`.

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
cat /sys/module/nvidia_drm/parameters/modeset # Y
exec desktop
```

[NVIDIA 550.163.01 cannot safely reload `nvidia-drm`](https://bugs.debian.org/1128843).
Systemd loads it at boot, so [`nvidia-kms.conf`](./etc/modprobe.d/nvidia-kms.conf)
makes modprobe apply `modeset=1` on its first load.

![Hyprland Desktop Screenshot](./hypr.webp)
