set -eu
test "$USER" = root || exec sudo sh "$0"

export DEBIAN_FRONTEND="noninteractive"
export NEEDRESTART_SUSPEND=1

# Refresh package lists.
apt update

# Upgrade packages.
apt full-upgrade --yes

# Base tools
apt install --yes \
	cron micro less rsync \
	git gh ssh kitty-terminfo \
	curl ca-certificates openssl \
	fd-find ripgrep tree file crudini jq pup \
	direnv needrestart fwupd \
	podman tailscale

# Development runtimes and tooling
apt install --yes \
	nodejs build-essential pkg-config \
	python3 python3-venv python3-pip python3-dev pipx \
	lua5.1 luarocks

needrestart -r a

# Hugging Face CLI
pipx upgrade --global --install \
	huggingface_hub

# Codex CLI
npm install --global --no-fund \
	@openai/codex
