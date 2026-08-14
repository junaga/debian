set -eu
LOG=/tmp/upgrade.log

# Skip if this script is already running.
exec 9<"$0"; flock --nonblock 9 || exit 0

echo "Output redirected to:"
echo "$LOG"

# Capture output and write failures to the journal.
exec >"$LOG" 2>&1
trap '[ $? != 0 ] && logger -t upgrade.sh <"$LOG"' 0

export DEBIAN_FRONTEND="noninteractive"

# Install security and package updates.
apt update
apt full-upgrade --yes

# Base tools
apt install --yes \
	cron micro less rsync \
	git gh ssh kitty-terminfo \
	curl ca-certificates openssl \
	fd-find ripgrep tree file crudini jq pup

# Development runtimes and tooling
apt install --yes \
	nodejs build-essential pkg-config \
	python3 python3-venv python3-pip python3-dev pipx \
	lua5.1 luarocks

# Codex CLI
npm install --global --no-fund \
	@openai/codex
