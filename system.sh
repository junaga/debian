# Set up a Debian machine with the shared configuration and tools used in this repository.
# Run it after a fresh Debian install, whether that is a container, WSL environment, VPS, or PC.
# It makes system-wide changes and arranges for the machine to stay updated afterward.

set -eu
test $(whoami) != "root" && exec sudo -E sh $0
cd $(dirname $0)

export DEBIAN_FRONTEND="noninteractive"
export NEEDRESTART_SUSPEND="1"

# Modernize APT sources.
apt modernize-sources --assume-yes

# Bootstrap HTTPS
apt update
apt install --yes ca-certificates

# Install configuration
cp -r base/. /etc/

# Install packages
apt update
apt install --yes \
	cron lsb-release micro less rsync \
	git gh ssh \
	1password-cli \
	curl wget openssl \
	fd-find ripgrep tree file crudini jq pup \
	direnv needrestart fwupd xorriso squashfs-tools systemd-container \
	podman \
	nodejs build-essential pkg-config \
	python3 python3-venv python3-pip python3-dev pipx \
	lua5.1 luarocks

# Install the verified Phosphor Debian release before retiring Kitty. `gh`
# authenticates against the private junaga/phosphor repository, so the release
# asset never needs to be exposed through a public APT source.
phosphor_dir=$(mktemp -d)
trap 'rm -rf "$phosphor_dir"' EXIT
gh release download v0.1.0-12 --repo junaga/phosphor \
	--pattern 'phosphor_*_amd64.deb' --dir "$phosphor_dir"
apt install --yes "$phosphor_dir"/phosphor_*_amd64.deb

# Kitty is deliberately absent from this image. Purge its executable, shell
# integration, and terminfo package only after Phosphor is installed. APT's
# autoremove pass removes only packages no longer required by any installed
# application; shared font, shaping, graphics, and Wayland libraries remain.
apt purge --yes kitty kitty-shell-integration kitty-terminfo
apt autoremove --yes

# Install deb-get
curl -L https://raw.githubusercontent.com/wimpysworld/deb-get/main/deb-get | bash -s install deb-get

# Install packages
deb-get install tailcat
pipx install --global huggingface_hub

npm install --global --no-fund @openai/codex

# Update every two minutes
echo "*/2 * * * * root sh /etc/update.sh" >> /etc/crontab
