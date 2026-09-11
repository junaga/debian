set -eu
test $(whoami) != "root" && exec sudo -E sh $0
cd $(dirname $0)

export DEBIAN_FRONTEND="noninteractive"
export NEEDRESTART_SUSPEND="1"

# Bootstrap HTTPS from signed Debian HTTP repositories
rm -f /etc/apt/sources.list
cp repo/debian.sources /etc/apt/sources.list.d/
apt update
apt install --yes ca-certificates

# Add third-party HTTPS repositories
cp -r repo/. /etc/apt/sources.list.d/

# Install packages
apt update
apt install --yes \
	cron micro less rsync \
	git gh ssh kitty-terminfo \
	curl openssl \
	fd-find ripgrep tree file crudini jq pup \
	direnv needrestart fwupd xorriso squashfs-tools systemd-container \
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
