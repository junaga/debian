set -e
cd "$(dirname "$0")"

# Bootstrap HTTPS with the existing Debian source.
apt update
apt install --yes ca-certificates

# Install Base repositories.
cp -ar repo/. /etc/apt/sources.list.d/
rm -f /etc/apt/sources.list

# Configure Base.
sh "$PWD/update.sh"

# Upgrade the system every 60 seconds.
echo "* * * * * root systemd-cat --identifier=update.sh sh $PWD/update.sh" >> /etc/crontab
