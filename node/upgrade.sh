DEBIAN="testing"

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
	nodejs npm build-essential \
	curl ca-certificates openssl \
	fd-find ripgrep tree file crudini jq pup

npm install --global --no-fund \
	@openai/codex
