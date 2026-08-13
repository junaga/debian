#!/bin/bash
set -e

DIR="$(dirname "$0")"
KERNEL_HEADERS="linux-headers-$(uname -r)"
USER_NAME="${1:?usage: $0 USER}"

if ! getent passwd "$USER_NAME" >/dev/null; then
	useradd --no-create-home --user-group --shell /bin/bash "$USER_NAME"
fi
USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"

function asUser {
	runuser --user "$USER_NAME" -- env HOME="$USER_HOME" "$@"
}

# ==============================================================================
# SYSTEM
# ==============================================================================

test "$(findmnt -n -T / -o FSTYPE)" = btrfs
btrfs subvolume show /home >/dev/null
apt install --yes btrfs-progs btrbk

mkdir -p "$USER_HOME"
chown "$USER_NAME:$USER_NAME" "$USER_HOME"
for skeleton in /etc/skel/.[!.]*; do
	test -e "$USER_HOME/${skeleton##*/}" || cp -a "$skeleton" "$USER_HOME/"
done
cp -ra "$DIR/home/." "$USER_HOME/."
chown -R "$USER_NAME:$USER_NAME" "$USER_HOME"
# Configuration files.
cp -ar "$DIR/etc/." /etc/.
systemctl enable --now btrbk.timer
swapon --show=NAME --noheadings | grep -Fx /swapfile >/dev/null || swapon /swapfile

# Root launches the graphical session for the explicitly named desktop user.
for PROGRAM in "$DIR"/bin/* "$DIR"/home/bin/*; do
	install -m 0755 "$PROGRAM" "/usr/local/bin/${PROGRAM##*/}"
done

# Fast boot: skip the GRUB menu and UEFI delay.
update-grub
efibootmgr --timeout 0

# ==============================================================================
# HARDWARE
# ==============================================================================

# NVIDIA graphics.
apt update
apt install --yes nvidia-driver-pinning-580
apt install --yes\
  firmware-misc-nonfree\
  'nvidia-driver=580*'\
  nvidia-settings\
  "$KERNEL_HEADERS";

# ==============================================================================
# SERVICES
# ==============================================================================

# NetworkManager with Cloudflare DNS.
apt install --yes network-manager
crudini --set /etc/NetworkManager/NetworkManager.conf ifupdown managed true
nmcli connection migrate
systemctl restart NetworkManager
crudini --set /etc/NetworkManager/NetworkManager.conf main plugins keyfile
crudini --set /etc/NetworkManager/NetworkManager.conf main rc-manager file
systemctl stop 'ifup@*.service'
systemctl disable --now networking
nmcli -t -f UUID,TYPE connection show | while IFS=: read -r uuid type; do
	case "$type" in
	802-3-ethernet|802-11-wireless) nmcli connection modify "$uuid" \
		ipv4.ignore-auto-dns yes ipv6.ignore-auto-dns yes ipv4.dns 1.1.1.1,1.0.0.1 ;;
	esac
done
systemctl restart NetworkManager

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
apt install --yes --allow-downgrades\
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
  xdg-desktop-portal-hyprland\
  xwayland;

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
asUser hyprpm add https://github.com/junaga/windows-pointer-linux
asUser hyprpm update
asUser hyprpm enable windows-pointer-linux
asUser hyprpm reload

# Passwordless desktop credential service.
apt install --yes gnome-keyring
asUser mkdir -p "$USER_HOME/.local/share/keyrings"
asUser crudini --set "$USER_HOME/.local/share/keyrings/login.keyring" keyring

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
# The official package registers OpenAI's signed APT repository for updates.
installURL "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb"
installGitHubRelease "th-ch/youtube-music" "_amd64.deb"
