set -eu
exec 9>/run/lock/system-update.lock
flock -n 9 || exit 0

. /etc/environment
export UV_TOOL_DIR UV_TOOL_BIN_DIR
export DEBIAN_FRONTEND="noninteractive"
export NEEDRESTART_MODE="a"

echo 'Starting host updates'
apt-get -o APT::Update::Error-Mode=any update
echo 'APT indexes refreshed'

# Limit these preferences to the scheduled APT invocation.
preferences=$(mktemp)
trap 'rm -f "$preferences"' EXIT
{
    cat /etc/apt/automatic-upgrade.pref
    printf '\n'
    cat /etc/apt/preferences
} > "$preferences"
apt-get -o "Dir::Etc::Preferences=$preferences" \
    --yes --with-new-pkgs --no-remove upgrade

DISABLE_APT=y deb-get update
deb-get upgrade --dg-only
uv self update
uv tool upgrade --all
npm update --global --no-fund --allow-scripts=@railway/cli,@stripe/cli,esbuild,workerd
echo 'Host updates complete'
