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

# Wayland Screenshots
apt install --yes\
  grim\
    slurp\
  wl-clipboard;

# Wayland Terminal emulator
apt install --yes\
  kitty\
  	wl-clipboard\
  fonts-noto\
  	fonts-noto-extra\
  	fonts-noto-cjk\
  	fonts-noto-cjk-extra\
  fonts-noto-color-emoji;

# Google Chrome
curl -L "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" > /tmp/google-chrome.deb
apt install /tmp/google-chrome.deb -y

# Cursor
curl -L "https://api2.cursor.sh/updates/download/golden/linux-x64-deb/cursor/2.5" > /tmp/cursor.deb
sudo apt install -y libsecret-1-0 gnome-keyring /tmp/cursor.deb
