set -e
cd "$(dirname "$0")"

# Bootstrap HTTPS with the existing Debian source.
apt update
apt install --yes ca-certificates

# Install Base repositories.
cp -ar repo/. /etc/apt/sources.list.d/
rm -f /etc/apt/sources.list

# Configure Base.
sh ./upgrade.sh

# Install security updates every 60 seconds.
SECURITY_UPGRADE='apt -t "$(. /etc/os-release && printf "%s-security" "$VERSION_CODENAME")" full-upgrade --yes'
echo "* * * * * root apt update && $SECURITY_UPGRADE" >> /etc/crontab
