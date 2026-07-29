set -e

SWAP="16G"
DIR="$(dirname "$0")"

cp -ar "$DIR/etc/." /etc/.

# faster PC boot (skip GRUB and UEFI sleep)
update-grub
efibootmgr --timeout 0

# file backups (Btrfs snapshots)
btrfs subvolume create /usr/local/.snapshots
apt install snapper --yes

# memory swap file (reserve memory)
if [ ! -e /var/swap ]; then
	fallocate -l $SWAP /var/swap
	chmod 600 /var/swap
	mkswap /var/swap
fi

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
  adwaita-icon-theme\
  hyprland\
  hyprland-backgrounds\
  hyprshutdown\
  systemd-timesyncd;

function installCursorTheme {
	local USER_NAME="${SUDO_USER:?Run desktop/install.sh with sudo.}"
	local USER_GROUP
	local USER_HOME
	local THEME

	USER_GROUP="$(id -gn "$USER_NAME")"
	USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"
	THEME="$USER_HOME/.local/share/icons/arrow-on-text"

	install -d -o "$USER_NAME" -g "$USER_GROUP" "$THEME/cursors"
	install -m 0644 -o "$USER_NAME" -g "$USER_GROUP" \
		"$DIR/home/.local/share/icons/arrow-on-text/index.theme" \
		"$THEME/index.theme"

	for SHAPE in text vertical-text xterm; do
		ln -sfn /usr/share/icons/Adwaita/cursors/default "$THEME/cursors/$SHAPE"
		chown -h "$USER_NAME:$USER_GROUP" "$THEME/cursors/$SHAPE"
	done
}

installCursorTheme

sudo --user "$SUDO_USER" hyprpm add https://github.com/junaga/windows-pointer-linux
sudo --user "$SUDO_USER" hyprpm update
sudo --user "$SUDO_USER" hyprpm enable windows-pointer-linux
sudo --user "$SUDO_USER" hyprpm reload

# Desktop Utilities
apt install --yes\
  dolphin\
  wl-clipboard\
    xclip\
  grim\
    slurp\
  playerctl\
  ffmpeg\
  wf-recorder;

# Wayland Terminal Emulator
apt install --yes\
  kitty\
  cargo\
  fonts-firacode\
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
