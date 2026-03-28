SWAP="16G"

# faster PC boot (skip UEFI and GRUB sleep)
efibootmgr --timeout 0
sed -i "s|GRUB_TIMEOUT=5|GRUB_TIMEOUT=0|" /etc/default/grub
rm -r /etc/default/grub.d/
update-grub

# memory swap file (reserve memory)
fallocate -l $SWAP /var/swap
chmod 600 /var/swap
mkswap /var/swap
echo "/var/swap none swap sw 0 0" >> /etc/fstab

# Audio and Bluetooth
apt install --yes\
  pipewire-audio\
  bluetooth;

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
installURL "https://github.com/ytmdesktop/ytmdesktop/releases/latest/download/youtube-music-desktop-app_amd64.deb"
installURL "https://github.com/ytmdesktop/ytmdesktop/releases/download/v2.0.0/youtube-music-desktop-app_2.0.0_amd64.deb"

npm install --global --no-fund webtorrent-cli
