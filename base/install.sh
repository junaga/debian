set -eu
test $(whoami) != "root" && exec sudo -E sh $0
cd $(dirname $0)

export DEBIAN_FRONTEND="noninteractive"
export NEEDRESTART_SUSPEND="1"

# Bootstrap HTTPS
apt update
apt install --yes ca-certificates

# Install repositories
cp -r repo/. /etc/apt/

# Install packages
apt update
apt install --yes \
	cron lsb-release micro less rsync \
	git gh ssh kitty-terminfo \
	1password-cli \
	curl wget openssl \
	fd-find ripgrep tree file crudini jq pup \
	direnv needrestart fwupd xorriso squashfs-tools systemd-container \
	podman \
	nodejs build-essential pkg-config \
	python3 python3-venv python3-pip python3-dev pipx \
	lua5.1 luarocks

# Install deb-get
curl -L https://raw.githubusercontent.com/wimpysworld/deb-get/main/deb-get | bash -s install deb-get

# Install packages
pipx install --global huggingface_hub
npm install --global --no-fund @openai/codex

# Update every two minutes
echo "*/2 * * * * root sh /etc/apt/update.sh" >> /etc/crontab
