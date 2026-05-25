SWAP="16G"
DESKTOP="$(dirname "$0")"

# faster PC boot (skip UEFI and GRUB sleep)
efibootmgr --timeout 0
sed -i "s|GRUB_TIMEOUT=5|GRUB_TIMEOUT=0|" /etc/default/grub
rm -r /etc/default/grub.d/
update-grub

# Virtual terminal autologin
systemctl enable getty@tty1.service
printf '%s\n' '[Service]' 'ExecStart=' 'ExecStart=-/usr/bin/login -f 1000' | systemctl edit getty@.service --stdin

# memory swap file (reserve memory)
if [ ! -e /var/swap ]; then
	fallocate -l $SWAP /var/swap
	chmod 600 /var/swap
	mkswap /var/swap
fi

install -Dm644 "$DESKTOP/var-swap.swap" /etc/systemd/system/var-swap.swap
systemctl enable --now var-swap.swap

# Audio and Bluetooth
apt install --yes\
  pipewire-audio\
    easyeffects\
  bluetooth\
  upower;

systemctl enable --now upower.service

# Secret Service is D-Bus activated; avoid starting a second daemon via systemd.
systemctl --global disable gnome-keyring-daemon.service gnome-keyring-daemon.socket

# todo: automate this
# bluetoothctl pair 3C:B0:ED:A7:96:8D
# bluetoothctl trust 3C:B0:ED:A7:96:8D
# bluetoothctl connect 3C:B0:ED:A7:96:8D
# wpctl status
# wpctl set-default 72   # bluez_input...  [Audio/Source]
# wpctl set-default 75   # bluez_output... [Audio/Sink]

# NVIDIA
apt install --yes\
  firmware-misc-nonfree\
  nvidia-driver\
  dkms\
  build-essential\
  linux-headers-amd64;

# NVIDIA DRM KMS for Wayland
echo "options nvidia_drm modeset=1" >> /etc/modprobe.d/nvidia-drm.conf
update-initramfs -u

# Hyprland
apt install --yes\
  hyprland\
  	hyprland-qtutils\
  hyprland-backgrounds\
  systemd-timesyncd;

# Desktop Utilities
apt install --yes\
  wl-clipboard\
    xclip\
  grim\
    slurp;

# Wayland Terminal Emulator
apt install --yes\
  kitty\
  fonts-noto\
  	fonts-noto-extra\
  	fonts-noto-cjk\
  	fonts-noto-cjk-extra\
  fonts-noto-color-emoji;

export DEBIAN_FRONTEND="noninteractive"

function installURL {
	local FILE=/tmp/$RANDOM.deb
	curl -fL "$1" > $FILE
	apt install --yes $FILE
}

installURL "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
installURL "https://discord.com/api/download?platform=linux&format=deb"
installURL "https://update.code.visualstudio.com/latest/linux-deb-x64/stable"

npm install --global --no-fund webtorrent-cli
