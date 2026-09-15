#!/bin/bash
set -e

cd -- "$(dirname -- "$0")"
KERNEL_HEADERS="linux-headers-$(uname -r)"
(( EUID != 0 )) || { echo "run as your desktop user (junaga), without sudo" >&2; exit 1; }

sudo -v

# ==============================================================================
# SYSTEM
# ==============================================================================

test "$(findmnt -n -T / -o FSTYPE)" = btrfs
sudo btrfs subvolume show /home >/dev/null
sudo apt install btrfs-progs btrbk dconf-cli atop smartmontools --yes

# Install home configuration as the current user.
cp -r --no-preserve=ownership ./home/. "$HOME/."
mkdir -p "$HOME/.config/dconf"
dconf compile "$HOME/.config/dconf/user" ./dconf.d
# Configuration files.
sudo visudo -cf ./etc/sudoers.d/desktop
sudo cp -r --no-preserve=ownership ./etc/. /etc/.
sudo install -d -m 0700 /var/log/atop
sudo chmod 0440 /etc/sudoers.d/desktop
sudo visudo -cf /etc/sudoers.d/desktop
sudo systemctl enable getty@tty2.service
sudo install -d -m 0700 /snapshots
sudo systemctl enable btrbk.timer --now
sudo systemctl daemon-reload
sudo systemctl enable --now var-lib-solidus-solidus.swap.swap

# Install desktop launchers and utilities.
for PROGRAM in ./bin/[^.]*; do
	[ -f "$PROGRAM" ] && [ -x "$PROGRAM" ] || continue
	sudo install -m 0755 "$PROGRAM" "/usr/local/bin/${PROGRAM##*/}"
done

sudo systemctl enable --now atop.service atop-rotate.timer performance-gpu.timer performance-report.timer
sudo systemctl restart atop.service


# Fast boot: skip the GRUB menu and UEFI delay.
sudo update-grub
sudo efibootmgr --timeout 0

# ==============================================================================
# HARDWARE
# ==============================================================================

# Temperature monitoring. This hardware exposes no Linux fan-control interface.
sudo apt install --yes --no-install-recommends lm-sensors

# NVIDIA graphics.
sudo apt update
sudo apt install nvidia-driver-pinning-580 --yes
sudo apt install --yes \
  firmware-misc-nonfree\
  'nvidia-driver=580*'\
  nvidia-settings\
  "$KERNEL_HEADERS";

# ==============================================================================
# SERVICES
# ==============================================================================

# systemd-networkd with iwd for Wi-Fi and static Cloudflare DNS.
sudo apt install iwd --yes
sudo systemctl disable networking.service --now
sudo systemctl enable systemd-networkd.service iwd.service --now

# Audio and Bluetooth
sudo apt install --yes \
  pipewire-audio\
    libspa-0.2-libcamera\
    pulseaudio-utils\
    easyeffects\
  bluetooth\
  upower;

# Enable BlueZ battery-provider and LE Audio support.
sudo crudini --set /etc/bluetooth/main.conf General Experimental true
sudo crudini --set /etc/bluetooth/main.conf General KernelExperimental true

sudo systemctl restart bluetooth.service
sudo systemctl enable upower.service --now

# TODO: Automate Bluetooth device setup.
# bluetoothctl pair 3C:B0:ED:A7:96:8D
# bluetoothctl trust 3C:B0:ED:A7:96:8D
# bluetoothctl connect 3C:B0:ED:A7:96:8D
# wpctl status
# wpctl set-default 72   # bluez_input...  [Audio/Source]
# wpctl set-default 75   # bluez_output... [Audio/Sink]

# Printing: modern driverless printers use IPP.
sudo apt install cups --yes;

# ==============================================================================
# DESKTOP
# ==============================================================================

# Hyprland desktop
sudo apt install --yes --target-release trixie-backports \
  adwaita-icon-theme\
  hyprland\
  hyprland-backgrounds\
  hyprland-dev\
  libaquamarine-dev\
  libhyprgraphics-dev\
  libhyprlang-dev\
  libhyprutils-dev\
  libhyprwire-dev\
  nwg-look\
  hyprshutdown\
  systemd-timesyncd\
  xdg-desktop-portal-gtk\
  xdg-desktop-portal-hyprland\
  xwayland;

# Replace text-selection cursors with the default pointer.
mkdir -p "$HOME/.local/share/icons/arrow-on-text/cursors"
for SHAPE in text vertical-text xterm; do
	ln -sfn /usr/share/icons/Adwaita/cursors/default \
		"$HOME/.local/share/icons/arrow-on-text/cursors/$SHAPE"
done

# Hyprland cursor-shape plugin.
hyprpm add https://github.com/junaga/windows-pointer-linux
hyprpm update
hyprpm enable windows-pointer-linux

# Debian PAM warns when vendor profiles are loaded directly from /usr/lib/pam.d.
# Preserve administrator profiles and keep links following package updates.
for SERVICE in systemd-user polkit-1; do
	if [ -f "/usr/lib/pam.d/$SERVICE" ] &&
		[ ! -e "/etc/pam.d/$SERVICE" ] && [ ! -L "/etc/pam.d/$SERVICE" ]; then
		sudo ln -s "/usr/lib/pam.d/$SERVICE" "/etc/pam.d/$SERVICE"
	fi
done

# Passwordless desktop credential service.
sudo apt install gnome-keyring --yes
mkdir -p "$HOME/.local/share/keyrings"
# An existing keyring may be encrypted and contain application credentials.
if [ ! -e "$HOME/.local/share/keyrings/login.keyring" ]; then
	crudini --set "$HOME/.local/share/keyrings/login.keyring" keyring
fi

# ==============================================================================
# APPLICATIONS
# ==============================================================================

# Desktop utilities
sudo apt install --yes \
  fuzzel\
  dolphin\
  wl-clipboard\
    xclip\
  grim\
    slurp\
  playerctl\
  ffmpeg\
  wf-recorder;

# Wayland terminal and fonts
sudo apt install --yes \
  kitty\
  cargo\
  fonts-firacode\
  fonts-noto\
    fonts-noto-extra\
    fonts-noto-cjk\
    fonts-noto-cjk-extra\
  fonts-noto-color-emoji;

# 3D creation
sudo apt install blender --yes

# Third-party desktop applications.
deb-get install google-chrome-stable discord code chatgpt youtube-music

# CSVLens is not published as a .deb, so install it from crates.io.
cargo install --locked --root "$HOME/.local" csvlens
