set -e

SWAP="12G"
DIR="$(dirname "$0")"
USER_NAME="${SUDO_USER:?Run desktop/install.sh with sudo.}"
USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"

function unsudo {
	sudo --user "$USER_NAME" "$@"
}

# ==============================================================================
# SYSTEM
# ==============================================================================

# Configuration files.
cp -ar "$DIR/etc/." /etc/.

# Filesystem-native recovery for user data.
apt install --yes btrfs-progs snapper
if ! btrfs subvolume show "$USER_HOME/.snapshots" >/dev/null 2>&1; then
	btrfs subvolume create "$USER_HOME/.snapshots"
fi
snapper --config home setup-quota
systemctl enable --now snapper-timeline.timer snapper-cleanup.timer

# Fast boot: skip the GRUB menu and UEFI delay.
update-grub
efibootmgr --timeout 0

# Reserve swap space for memory pressure.
if [ ! -e /var/swap ]; then
	fallocate -l $SWAP /var/swap
	chmod 600 /var/swap
	mkswap /var/swap
fi

# ==============================================================================
# HARDWARE
# ==============================================================================

# NVIDIA graphics.
apt install --yes\
  firmware-misc-nonfree\
  nvidia-driver\
  dkms\
  build-essential\
  linux-headers-$(uname -r);

# Rebuild the initramfs for the installed NVIDIA DKMS modules.
update-initramfs -u

# ==============================================================================
# SERVICES
# ==============================================================================

# Audio and Bluetooth
apt install --yes\
  pipewire-audio\
    libspa-0.2-libcamera\
    pulseaudio-utils\
    easyeffects\
  bluetooth\
  upower;

# Enable BlueZ battery-provider and LE Audio support.
crudini --set /etc/bluetooth/main.conf General Experimental true
crudini --set /etc/bluetooth/main.conf General KernelExperimental true

systemctl restart bluetooth.service
systemctl enable --now upower.service

# TODO: Automate Bluetooth device setup.
# bluetoothctl pair 3C:B0:ED:A7:96:8D
# bluetoothctl trust 3C:B0:ED:A7:96:8D
# bluetoothctl connect 3C:B0:ED:A7:96:8D
# wpctl status
# wpctl set-default 72   # bluez_input...  [Audio/Source]
# wpctl set-default 75   # bluez_output... [Audio/Sink]

# Printing: modern driverless printers use IPP.
apt install --yes cups;

# ==============================================================================
# DESKTOP
# ==============================================================================

# Hyprland desktop
apt install --yes\
  adwaita-icon-theme\
  hyprland\
  nwg-look\
  hyprshutdown\
  systemd-timesyncd;

# Replace text-selection cursors with the default pointer.
function installCursorTheme {
	local USER_GROUP
	local THEME

	USER_GROUP="$(id -gn "$USER_NAME")"
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

# Hyprland cursor-shape plugin.
unsudo hyprpm add https://github.com/junaga/windows-pointer-linux
unsudo hyprpm update
unsudo hyprpm enable windows-pointer-linux
unsudo hyprpm reload

# Passwordless desktop credential service.
apt install --yes gnome-keyring
unsudo mkdir -p "$USER_HOME/.local/share/keyrings"
unsudo crudini --set "$USER_HOME/.local/share/keyrings/login.keyring" keyring

# ==============================================================================
# APPLICATIONS
# ==============================================================================

# Desktop utilities
apt install --yes\
  dolphin\
  wl-clipboard\
    xclip\
  grim\
    slurp\
  playerctl\
  ffmpeg\
  wf-recorder;

# Wayland terminal and fonts
apt install --yes\
  kitty\
  cargo\
  fonts-firacode\
  fonts-noto\
    fonts-noto-extra\
    fonts-noto-cjk\
    fonts-noto-cjk-extra\
  fonts-noto-color-emoji;

# Third-party desktop applications
function installURL {
	(
		local FILE

		FILE="$(mktemp --suffix=.deb)"
		trap 'rm -f "$FILE"' EXIT
		curl -fL --output "$FILE" "$1"
		apt install --yes "$FILE"
	)
}

function installGitHubRelease {
	local REPOSITORY="$1"
	local SUFFIX="$2"
	local URL

	URL="$(curl -fsSL "https://api.github.com/repos/$REPOSITORY/releases/latest" |
		jq -er --arg suffix "$SUFFIX" \
		'.assets | map(select(.name | endswith($suffix))) | first | .browser_download_url')"
	installURL "$URL"
}

installURL "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
installURL "https://discord.com/api/download?platform=linux&format=deb"
installURL "https://update.code.visualstudio.com/latest/linux-deb-x64/stable"
installGitHubRelease "junaga/chatgpt" "chatgpt.deb"
installGitHubRelease "th-ch/youtube-music" "_amd64.deb"
