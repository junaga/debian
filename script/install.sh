# this script needs /bin and /sbin, login as root!

# faster PC boot (skip UEFI and GRUB sleep)
efibootmgr --timeout 0
sed -i "s|GRUB_TIMEOUT=5|GRUB_TIMEOUT=0|" /etc/default/grub
rm -r /etc/default/grub.d/
update-grub

# memory swap file (16 GB reserve memory)
fallocate -l 16G /var/swap
chmod 600 /var/swap
mkswap /var/swap
echo "/var/swap none swap sw 0 0" >> /etc/fstab


# Audio and Bluetooth
apt install\
  pipewire-audio\
  bluetooth\
  --yes;

# todo: automate this
# bluetoothctl pair 3C:B0:ED:A7:96:8D
# bluetoothctl trust 3C:B0:ED:A7:96:8D
# bluetoothctl connect 3C:B0:ED:A7:96:8D
# wpctl status
# wpctl set-default 72   # bluez_input...  [Audio/Source]
# wpctl set-default 75   # bluez_output... [Audio/Sink]

# NVIDIA
# Make sure contrib and non-free Debian packages are enabled in apt.
# Make sure you manually disable "Secure Boot" in UEFI settings.
#   apt:nvidia-driver is not installed it's compiled (apt:dkms)
#   installing the package installs the source code
#   then it compiles then installs the actual driver binaries
apt install\
  firmware-misc-nonfree\
  nvidia-driver\
  dkms\
  build-essential\
  linux-headers-amd64\
  --yes;

# NVIDIA DRM KMS for Wayland
echo "options nvidia_drm modeset=1" >> /etc/modprobe.d/nvidia-drm.conf
update-initramfs -u


# Hyprland
apt install\
  hyprland\
  	hyprland-qtutils\
  hyprland-backgrounds\
  --yes;

# Wayland Screenshots
apt install\
  grim\
    slurp\
  wl-clipboard\
  --yes;

# Wayland Terminal emulator
apt install\
  --no-install-recommends\
  kitty\
  	wl-clipboard\
  fonts-noto\
  	fonts-noto-extra\
  	fonts-noto-cjk\
  	fonts-noto-cjk-extra\
  fonts-noto-color-emoji\
  --yes;


# Google Chrome
curl -L https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb > ./google-chrome.deb
apt install ./google-chrome.deb -y
rm ./google-chrome.deb
# I use $HOME/dl/ for downloads
