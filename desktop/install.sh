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
  hyprland\
  hyprland-backgrounds\
  hyprshutdown\
  systemd-timesyncd;

function installWindowsPointer {
	local USER_NAME="${SUDO_USER:?Run desktop/install.sh with sudo.}"
	local USER_HOME
	USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"

	if sudo --user "$USER_NAME" env HOME="$USER_HOME" hyprpm list |
		grep --quiet "Repository windows-pointer-linux"; then
		sudo --user "$USER_NAME" env HOME="$USER_HOME" hyprpm update
	else
		printf "y\n" |
			sudo --user "$USER_NAME" env HOME="$USER_HOME" hyprpm add \
				https://github.com/junaga/windows-pointer-linux \
				5da916bbde44baa8824b2ca55ef55c92b73418ae
	fi

	sudo --user "$USER_NAME" env HOME="$USER_HOME" \
		hyprpm enable windows-pointer-linux
}

installWindowsPointer

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

function installCRTty {
	local DIR
	DIR="$(mktemp -d)"

	git clone --quiet https://github.com/kosa12/CRTty.git "$DIR"
	git -C "$DIR" checkout --quiet 673f61528a7640299719c07a380d0b87841a4aa3
	cargo build --quiet --release --workspace --manifest-path "$DIR/Cargo.toml"

	install -m 755 "$DIR/target/release/crtty" /usr/local/bin/crtty
	install -m 755 "$DIR/target/release/libcrtty_crt.so" /usr/local/lib/libcrtty_crt.so
}

installCRTty

installURL "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
installURL "https://discord.com/api/download?platform=linux&format=deb"
installURL "https://update.code.visualstudio.com/latest/linux-deb-x64/stable"
