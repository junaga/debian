set -eu
test $(whoami) = root || exec sudo sh $0
export DEBIAN_FRONTEND="noninteractive"
export NEEDRESTART_MODE="a"

apt update
apt full-upgrade --yes

pipx upgrade-all --global
npm update --global --no-fund
