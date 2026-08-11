# Desktop

## NVIDIA GPU, [hypr.land](https://hypr.land) and Google Chrome

Make sure you manually disable `Secure Boot` in `UEFI`; Because `apt:nvidia-driver` is not installed, it's compiled with `apt:dkms`. Installing `apt:nvidia-driver` installs the source code, then it compiles, then installs the actual driver software. But the newly compiled software has no cryptographic release signature, which is required for `Secure Boot`.

Run these commands from the repository root.

```sh
sudo bash ./base/upgrade.sh
sudo cp -ra ./base/home/. /root/.

sudo bash ./desktop/install.sh
sudo cp -ra ./desktop/home/. /home/hypr/.
sudo chown -R hypr:hypr /home/hypr

sudo reboot 0
```

```sh
# From the root VT:
exec desktop
```

![Hyprland Desktop Screenshot](./hypr.webp)
