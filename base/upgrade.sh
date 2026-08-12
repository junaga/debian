#!/bin/bash
# Run repeatedly on every system.
set -e

test -f /etc/apt/sources.list && mv /etc/apt/{sources.list,sources.list.disabled}

# run Patch
export DEBIAN_FRONTEND="noninteractive"
apt update --allow-releaseinfo-change
apt full-upgrade --yes
apt autoremove --purge --yes
apt clean

# get Packages
apt install --yes \
	cron micro less rsync \
	git gh ssh kitty-terminfo \
	nodejs npm build-essential pkg-config \
	python3 python3-venv python3-pip python3-dev pipx \
	lua5.1 luarocks \
	curl ca-certificates openssl \
	fd-find ripgrep tree file crudini jq pup

npm install --global --no-fund \
	@openai/codex
