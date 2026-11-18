set -eu
exec 9>/run/lock/system-update.lock
flock -n 9 || exit 0

. /etc/environment
export UV_TOOL_DIR UV_TOOL_BIN_DIR
export DEBIAN_FRONTEND="noninteractive"
export NEEDRESTART_MODE="a"

echo 'Starting host updates'
apt update
apt full-upgrade --yes
DISABLE_APT=y deb-get update
deb-get upgrade --dg-only
uv self update
uv tool upgrade --all
npm update --global --no-fund --allow-scripts=@railway/cli,@stripe/cli,esbuild,workerd
echo 'Host updates complete'
