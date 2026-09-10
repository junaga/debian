set -eu
test $(whoami) = root || exec sudo sh $0
cd $(dirname $0)

export DEBIAN_FRONTEND="noninteractive"
export NEEDRESTART_SUSPEND="1"

# Enable HTTPS
apt update
apt install --yes ca-certificates

# Configure repositories
rm -f /etc/apt/sources.list
cp -r repo/. /etc/apt/sources.list.d/

# Install packages
apt update
apt install --yes \
	cron micro less rsync \
	git gh ssh kitty-terminfo \
	curl openssl \
	fd-find ripgrep tree file crudini jq pup \
	direnv needrestart fwupd xorriso squashfs-tools \
	podman tailscale \
	nodejs build-essential pkg-config \
	python3 python3-venv python3-pip python3-dev pipx \
	lua5.1 luarocks

# Install global tools
pipx install --global huggingface_hub
npm install --global --no-fund @openai/codex

# Update every minute
cp update.sh /etc/apt/update.sh
echo "* * * * * root sh /etc/apt/update.sh" >> /etc/crontab
