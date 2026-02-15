# this script needs /bin and /sbin, login as root!

# faster PC boot
efibootmgr --timeout 0
sed -i "s|GRUB_TIMEOUT=5|GRUB_TIMEOUT=0|" /etc/default/grub
rm -r /etc/default/grub.d/
update-grub

# memory swap file
fallocate -l 16G /var/swap
chmod 600 /var/swap
mkswap /var/swap
echo "/var/swap none swap sw 0 0" >> /etc/fstab

# Audio and Bluetooth
apt install\
  pipewire-audio\
  bluetooth\
  --yes;
	# bluetoothctl
	# >power on
	# >agent on
	# >default-agent
	# >scan on
	# >pair XX:XX:XX:XX:XX:XX
	# >trust XX:XX:XX:XX:XX:XX
	# >connect XX:XX:XX:XX:XX:XX
	# >quit
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
# polkit-kde-agent-1

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
# $HOME/dl/ for downloads
