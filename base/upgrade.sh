set -eu

export DEBIAN_FRONTEND="noninteractive"
export NEEDRESTART_SUSPEND=1

# Refresh package lists.
apt -qq update

# Upgrade packages.
apt -qq full-upgrade --yes

# Base tools
apt -qq install --yes \
	cron micro less rsync \
	git gh ssh kitty-terminfo \
	curl ca-certificates openssl \
	fd-find ripgrep tree file crudini jq pup \
	direnv needrestart \
	podman

# Development runtimes and tooling
apt -qq install --yes \
	nodejs build-essential pkg-config \
	python3 python3-venv python3-pip python3-dev pipx \
	lua5.1 luarocks

needrestart --restart a

# Codex CLI
npm install --global --no-fund --loglevel=warn \
	@openai/codex
