#!/bin/bash
set -e

cd -- "$(dirname -- "$0")"
KERNEL_HEADERS="linux-headers-$(uname -r)"
apt install --yes sudo
bash ./local-user.sh
USER_NAME=local
USER_HOME=/home/local

function asUser {
	runuser --user "$USER_NAME" -- env HOME="$USER_HOME" "$@"
}

# ==============================================================================
# SYSTEM
# ==============================================================================

test "$(findmnt -n -T / -o FSTYPE)" = btrfs
btrfs subvolume show /home >/dev/null
apt install btrfs-progs btrbk --yes

# Copy as the target user instead of recursively changing unrelated home state.
for skeleton in /etc/skel/.[!.]*; do
	test -e "$skeleton" || test -L "$skeleton" || continue
	if ! test -e "$USER_HOME/${skeleton##*/}" && ! test -L "$USER_HOME/${skeleton##*/}"; then
		asUser cp -r --no-preserve=ownership "$skeleton" "$USER_HOME/"
	fi
done
asUser cp -r --no-preserve=ownership ./home/. "$USER_HOME/."
# Configuration files.
cp -ar ./etc/. /etc/.
systemctl enable getty@tty2.service
systemctl enable btrbk.timer --now
swapon --show=NAME --noheadings | grep -Fx /swapfile >/dev/null || swapon /swapfile

# Install the desktop launcher and utilities.
for PROGRAM in ./bin/* ./home/bin/*; do
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
apt install nvidia-driver-pinning-580 --yes
apt install --yes \
  firmware-misc-nonfree\
  'nvidia-driver=580*'\
  nvidia-settings\
  "$KERNEL_HEADERS";

# ==============================================================================
# SERVICES
# ==============================================================================

# systemd-networkd with iwd for Wi-Fi and static Cloudflare DNS.
apt install iwd --yes
systemctl disable networking.service --now
systemctl enable systemd-networkd.service iwd.service --now

# Audio and Bluetooth
apt install --yes \
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
systemctl enable upower.service --now

# TODO: Automate Bluetooth device setup.
# bluetoothctl pair 3C:B0:ED:A7:96:8D
# bluetoothctl trust 3C:B0:ED:A7:96:8D
# bluetoothctl connect 3C:B0:ED:A7:96:8D
# wpctl status
# wpctl set-default 72   # bluez_input...  [Audio/Source]
# wpctl set-default 75   # bluez_output... [Audio/Sink]

# Printing: modern driverless printers use IPP.
apt install cups --yes;

# ==============================================================================
# DESKTOP
# ==============================================================================

# Hyprland desktop
apt install --yes --target-release trixie-backports \
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
		./home/.local/share/icons/arrow-on-text/index.theme \
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
apt install gnome-keyring --yes
asUser mkdir -p "$USER_HOME/.local/share/keyrings"
# An existing keyring may be encrypted and contain application credentials.
if [ ! -e "$USER_HOME/.local/share/keyrings/login.keyring" ]; then
	asUser crudini --set "$USER_HOME/.local/share/keyrings/login.keyring" keyring
fi

# ==============================================================================
# APPLICATIONS
# ==============================================================================

# Desktop utilities
apt install --yes \
  dolphin\
  wl-clipboard\
    xclip\
  grim\
    slurp\
  playerctl\
  ffmpeg\
  wf-recorder;

# Wayland terminal and fonts
apt install --yes \
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
		apt install "$FILE" --yes
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

function installGitHubReleaseBinary {
	(
		local REPOSITORY="$1"
		local ASSET="$2"
		local BINARY="$3"
		local DIRECTORY
		local URL

		DIRECTORY="$(mktemp -d)"
		trap 'rm -rf "$DIRECTORY"' EXIT
		URL="$(curl -fsSL "https://api.github.com/repos/$REPOSITORY/releases/latest" |
			jq -er --arg asset "$ASSET" \
			'.assets | map(select(.name == $asset)) | first | .browser_download_url')"
		curl -fL --output "$DIRECTORY/$ASSET" "$URL"
		curl -fL --output "$DIRECTORY/$ASSET.sha256" "$URL.sha256"
		(cd "$DIRECTORY" && sha256sum --check "$ASSET.sha256")
		tar -xJf "$DIRECTORY/$ASSET" -C "$DIRECTORY"
		install -m 0755 "$DIRECTORY/${ASSET%.tar.xz}/$BINARY" "/usr/local/bin/$BINARY"
	)
}

installURL "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
installURL "https://discord.com/api/download?platform=linux&format=deb"
installURL "https://update.code.visualstudio.com/latest/linux-deb-x64/stable"
# The official package registers OpenAI's signed APT repository for updates.
installURL "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb"
installGitHubRelease "th-ch/youtube-music" "_amd64.deb"
installGitHubReleaseBinary "YS-L/csvlens" \
	"csvlens-x86_64-unknown-linux-gnu.tar.xz" "csvlens"
