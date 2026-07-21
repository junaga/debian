SWAP="16G"
DIR="$(dirname "$0")"

cp -ar "$DIR/etc/." /etc/.

# faster PC boot (skip GRUB and UEFI sleep)
update-grub
efibootmgr --timeout 0

# file backups (Btrfs snapshots)
btrfs subvolume create /usr/local/.snapshots
apt install snapper --yes

# Local filesystems
sed -i '\|^# /usr/local was on /dev/sda3 during installation$|d; \|^UUID=47e498ee-c3ec-4708-b732-747c122114c0[[:space:]]\+/usr/local[[:space:]]|d; \|^# /usr/local/old was on /dev/sdb1 during installation$|d; \|^UUID=44db4ead-1413-4041-b963-33e5c634c381[[:space:]]\+/usr/local/old[[:space:]]|d' /etc/fstab
systemctl enable usr-local.mount usr-local-old.mount

# memory swap file (reserve memory)
if [ ! -e /var/swap ]; then
	fallocate -l $SWAP /var/swap
	chmod 600 /var/swap
	mkswap /var/swap
fi

systemctl enable --now var-swap.swap

# Audio and Bluetooth
apt install --yes\
  pipewire-audio\
    libspa-0.2-libcamera\
    pulseaudio-utils\
    easyeffects\
  bluetooth\
  upower;

systemctl enable --now upower.service

# Unix print service (enables modern driverless printing with IPP)
apt install --yes cups;

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
  linux-headers-$(uname -r);

# NVIDIA DRM KMS for Wayland
update-initramfs -u

# Hyprland
apt install --yes\
  hyprland\
 	hyprland-qtutils\
  hyprland-backgrounds\
  systemd-timesyncd;

ln -sf "$(readlink -f "$DIR/boot")" /usr/local/bin/desktop

# Desktop Utilities
apt install --yes\
  wl-clipboard\
    xclip\
  grim\
    slurp\
  ffmpeg\
  wf-recorder;

ln -sf "$(readlink -f "$DIR/recorder")" /usr/local/bin/recorder
install -Dm755 "$DIR/keycast.py" /usr/local/bin/keycast

# Wayland Terminal Emulator
apt install --yes\
  kitty\
  fonts-noto\
  	fonts-noto-extra\
  	fonts-noto-cjk\
  	fonts-noto-cjk-extra\
  fonts-noto-color-emoji;

function installURL {
	local FILE=/tmp/$RANDOM.deb
	curl -fL "$1" > $FILE
	apt install --yes $FILE
}

installURL "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
installURL "https://discord.com/api/download?platform=linux&format=deb"
installURL "https://update.code.visualstudio.com/latest/linux-deb-x64/stable"
