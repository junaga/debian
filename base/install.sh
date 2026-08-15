set -e
cd "$(dirname "$0")"

# Bootstrap HTTPS with the existing Debian source.
apt update
apt install --yes ca-certificates

# Install Base repositories.
cp -ar repo/. /etc/apt/sources.list.d/
rm -f /etc/apt/sources.list

# Upgrade.
sh ./update.sh

# Upgrade every 60 seconds.
cp ./update.sh /etc/apt/update.sh
echo "* * * * * root systemd-cat --identifier=update.sh sh /etc/apt/update.sh" >> /etc/crontab
