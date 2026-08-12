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

The NVIDIA DRM option must be applied on the module's first load; the current
driver cannot be safely hot-reloaded on this machine. The loading chain and
failure evidence are documented in
[`fixes.md`](../fixes.md#load-nvidia-drm-modesetting-once-at-boot).

![Hyprland Desktop Screenshot](./hypr.webp)
