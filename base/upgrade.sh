set -eu

export DEBIAN_FRONTEND="noninteractive"

# Upgrade the full system.
apt update
apt full-upgrade --yes

# Base tools
apt install --yes \
	cron micro less rsync \
	git gh ssh kitty-terminfo \
	curl ca-certificates openssl \
	fd-find ripgrep tree file crudini jq pup \
	direnv \
	podman

# Development runtimes and tooling
apt install --yes \
	nodejs build-essential pkg-config \
	python3 python3-venv python3-pip python3-dev pipx \
	lua5.1 luarocks

# Codex CLI
npm install --global --no-fund \
	@openai/codex
