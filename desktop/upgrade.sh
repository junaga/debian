SWAP="16G"
DESKTOP="$(dirname "$0")"
export DEBIAN_FRONTEND="noninteractive"

# faster PC boot (skip UEFI and GRUB sleep)
efibootmgr --timeout 0
sed -i "s|^GRUB_TIMEOUT=.*|GRUB_TIMEOUT=1|" /etc/default/grub
rm -rf /etc/default/grub.d/
update-grub

# Local filesystems
install -Dm644 "$DESKTOP/sys/usr-local.mount" /etc/systemd/system/usr-local.mount
install -Dm644 "$DESKTOP/sys/usr-local-old.mount" /etc/systemd/system/usr-local-old.mount
sed -i '\|^# /usr/local was on /dev/sda3 during installation$|d; \|^UUID=47e498ee-c3ec-4708-b732-747c122114c0[[:space:]]\+/usr/local[[:space:]]|d; \|^# /usr/local/old was on /dev/sdb1 during installation$|d; \|^UUID=44db4ead-1413-4041-b963-33e5c634c381[[:space:]]\+/usr/local/old[[:space:]]|d' /etc/fstab
systemctl enable usr-local.mount usr-local-old.mount

# Virtual terminal autologin
systemctl enable getty@tty1.service
printf '%s\n' '[Service]' 'ExecStart=' "ExecStart=-/usr/sbin/agetty --autologin $(getent passwd 1000 | cut -d: -f1) --noreset --noclear - \${TERM}" | systemctl edit getty@.service --stdin

# memory swap file (reserve memory)
if [ ! -e /var/swap ]; then
	fallocate -l $SWAP /var/swap
	chmod 600 /var/swap
	mkswap /var/swap
fi

install -Dm644 "$DESKTOP/sys/var-swap.swap" /etc/systemd/system/var-swap.swap
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
  linux-headers-$(uname -r);

# NVIDIA DRM KMS for Wayland
install -Dm644 "$DESKTOP/sys/nvidia-drm.conf" /etc/modprobe.d/nvidia-drm.conf
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

function installURL {
	local FILE=/tmp/$RANDOM.deb
	curl -fL "$1" > $FILE
	apt install --yes $FILE
}

installURL "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
installURL "https://discord.com/api/download?platform=linux&format=deb"
installURL "https://update.code.visualstudio.com/latest/linux-deb-x64/stable"
