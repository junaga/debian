DEBIAN="testing"
set -e

# set Config
test -f /etc/apt/sources.list && mv /etc/apt/{sources.list,sources.list.disabled}
cat > /etc/apt/sources.list.d/debian.sources <<-EOF
	Types: deb
	URIs: http://deb.debian.org/debian
	Suites: $DEBIAN
	Components: main contrib non-free non-free-firmware
	Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF

# run Patch
export DEBIAN_FRONTEND="noninteractive"
apt update --allow-releaseinfo-change
apt full-upgrade --yes
apt autoremove --purge --yes
apt clean

# get Packages
apt install --yes \
	micro less rsync sudo \
	git ssh kitty-terminfo \
	nodejs npm build-essential pkg-config \
	python3 python3-venv python3-pip python3-dev pipx \
	lua5.1 luarocks \
	curl ca-certificates openssl \
	fd-find ripgrep tree file crudini jq pup

npm install --global --no-fund \
	@openai/codex

# WSL and containers inherit networking from their host.
systemd-detect-virt --container --quiet && exit

# replace ifupdown with NetworkManager
apt install --yes network-manager
crudini --set /etc/NetworkManager/NetworkManager.conf ifupdown managed true
systemctl restart NetworkManager
nmcli connection migrate
crudini --set /etc/NetworkManager/NetworkManager.conf main plugins keyfile
systemctl disable networking
