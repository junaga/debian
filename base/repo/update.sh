set -eu

export DEBIAN_FRONTEND="noninteractive"
export NEEDRESTART_MODE="a"

apt update
apt full-upgrade --yes
deb-get update
deb-get upgrade --dg-only
pipx upgrade-all --global
curl -fsSL https://chatgpt.com/codex/install.sh | \
	CODEX_HOME=/usr/local/lib/codex \
	CODEX_INSTALL_DIR=/usr/local/bin \
	CODEX_NON_INTERACTIVE=1 \
	sh
