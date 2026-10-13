set -eu
exec 9>/run/lock/system-update.lock
flock -n 9 || exit 0
set -a; . /etc/environment; set +a

export DEBIAN_FRONTEND="noninteractive"
export NEEDRESTART_MODE="a"

apt update
apt full-upgrade --yes
deb-get update
deb-get upgrade --dg-only
uv self update
uv tool upgrade --all
npm update --global --no-fund --allow-scripts=@railway/cli,esbuild,workerd
