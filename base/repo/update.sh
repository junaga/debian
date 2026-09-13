set -eu

export DEBIAN_FRONTEND="noninteractive"
export NEEDRESTART_MODE="a"

apt update
apt full-upgrade --yes
deb-get update
deb-get upgrade --dg-only
pipx upgrade-all --global
npm update --global --no-fund
