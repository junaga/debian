#!/bin/bash
set -e

cd -- "$(dirname -- "$0")"
KERNEL_HEADERS="linux-headers-$(uname -r)"
(( EUID != 0 )) || { echo "run as your desktop user (junaga), without sudo" >&2; exit 1; }

sudo -v

# ==============================================================================
# SYSTEM
# ==============================================================================

test "$(findmnt -n -T / -o FSTYPE)" = btrfs
sudo btrfs subvolume show /home >/dev/null
sudo apt install btrfs-progs btrbk dconf-cli --yes

# Install home configuration as the current user.
cp -r --no-preserve=ownership ./home/. "$HOME/."
mkdir -p "$HOME/.config/dconf"
dconf compile "$HOME/.config/dconf/user" ./dconf.d
# Configuration files.
sudo visudo -cf ./etc/sudoers.d/desktop
sudo cp -r --no-preserve=ownership ./etc/. /etc/.
sudo systemd-tmpfiles --create /etc/tmpfiles.d/archive.conf
sudo chmod 0440 /etc/sudoers.d/desktop
sudo visudo -cf /etc/sudoers.d/desktop
sudo systemctl enable getty@tty2.service
sudo install -d -m 0700 /snapshots
sudo systemctl enable btrbk.timer --now
swapon --show=NAME --noheadings | grep -Fx /swapfile >/dev/null || sudo swapon /swapfile

# Install the desktop launcher and utilities.
for PROGRAM in ./bin/* ./home/bin/*; do
	sudo install -m 0755 "$PROGRAM" "/usr/local/bin/${PROGRAM##*/}"
done


# Fast boot: skip the GRUB menu and UEFI delay.
sudo update-grub
sudo efibootmgr --timeout 0

# ==============================================================================
# HARDWARE
# ==============================================================================

# Motherboard temperature/RPM readings and temperature-based fan control tools.
sudo bash ./install-hardware-control.sh

# NVIDIA graphics.
sudo apt update
sudo apt install nvidia-driver-pinning-580 --yes
sudo apt install --yes \
  firmware-misc-nonfree\
  'nvidia-driver=580*'\
  nvidia-settings\
  "$KERNEL_HEADERS";

# ==============================================================================
# SERVICES
# ==============================================================================

# systemd-networkd with iwd for Wi-Fi and static Cloudflare DNS.
sudo apt install iwd --yes
sudo systemctl disable networking.service --now
sudo systemctl enable systemd-networkd.service iwd.service --now

# Audio and Bluetooth
sudo apt install --yes \
  pipewire-audio\
    libspa-0.2-libcamera\
    pulseaudio-utils\
    easyeffects\
  bluetooth\
  upower;

# Enable BlueZ battery-provider and LE Audio support.
sudo crudini --set /etc/bluetooth/main.conf General Experimental true
sudo crudini --set /etc/bluetooth/main.conf General KernelExperimental true

sudo systemctl restart bluetooth.service
sudo systemctl enable upower.service --now

# TODO: Automate Bluetooth device setup.
# bluetoothctl pair 3C:B0:ED:A7:96:8D
# bluetoothctl trust 3C:B0:ED:A7:96:8D
# bluetoothctl connect 3C:B0:ED:A7:96:8D
# wpctl status
# wpctl set-default 72   # bluez_input...  [Audio/Source]
# wpctl set-default 75   # bluez_output... [Audio/Sink]

# Printing: modern driverless printers use IPP.
sudo apt install cups --yes;

# ==============================================================================
# DESKTOP
# ==============================================================================

# Hyprland desktop
sudo apt install --yes --target-release trixie-backports \
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
  xdg-desktop-portal-gtk\
  xdg-desktop-portal-hyprland\
  xwayland;

# Replace text-selection cursors with the default pointer.
mkdir -p "$HOME/.local/share/icons/arrow-on-text/cursors"
for SHAPE in text vertical-text xterm; do
	ln -sfn /usr/share/icons/Adwaita/cursors/default \
		"$HOME/.local/share/icons/arrow-on-text/cursors/$SHAPE"
done

# Hyprland cursor-shape plugin.
hyprpm add https://github.com/junaga/windows-pointer-linux
hyprpm update
hyprpm enable windows-pointer-linux

# Debian PAM warns when vendor profiles are loaded directly from /usr/lib/pam.d.
# Preserve administrator profiles and keep links following package updates.
for SERVICE in systemd-user polkit-1; do
	if [ -f "/usr/lib/pam.d/$SERVICE" ] &&
		[ ! -e "/etc/pam.d/$SERVICE" ] && [ ! -L "/etc/pam.d/$SERVICE" ]; then
		sudo ln -s "/usr/lib/pam.d/$SERVICE" "/etc/pam.d/$SERVICE"
	fi
done

# Passwordless desktop credential service.
sudo apt install gnome-keyring --yes
mkdir -p "$HOME/.local/share/keyrings"
# An existing keyring may be encrypted and contain application credentials.
if [ ! -e "$HOME/.local/share/keyrings/login.keyring" ]; then
	crudini --set "$HOME/.local/share/keyrings/login.keyring" keyring
fi

# ==============================================================================
# APPLICATIONS
# ==============================================================================

# Desktop utilities
sudo apt install --yes \
  fuzzel\
  dolphin\
  wl-clipboard\
    xclip\
  grim\
    slurp\
  playerctl\
  ffmpeg\
  wf-recorder;

# Wayland terminal and fonts
sudo apt install --yes \
  kitty\
  cargo\
  fonts-firacode\
  fonts-noto\
    fonts-noto-extra\
    fonts-noto-cjk\
    fonts-noto-cjk-extra\
  fonts-noto-color-emoji;

# 3D creation
sudo apt install blender --yes

# Third-party desktop applications
function installURL {
	(
		local FILE

		FILE="$(mktemp --suffix=.deb)"
		trap 'rm -f "$FILE"' EXIT
		curl -fL --output "$FILE" "$1"
		sudo apt install "$FILE" --yes
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
		sudo install -m 0755 "$DIRECTORY/${ASSET%.tar.xz}/$BINARY" "/usr/local/bin/$BINARY"
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
