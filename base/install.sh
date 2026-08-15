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
echo "* * * * * root apt update -q && apt -t trixie-security full-upgrade --yes" >> /etc/crontab
