set -e
cd "$(dirname "$0")"

# Bootstrap HTTPS with the existing Debian source.
apt update
apt install --yes ca-certificates

# Install Base repositories.
cp -ar repos/. /etc/apt/sources.list.d/
rm -f /etc/apt/sources.list

# Configure Base.
sh ./upgrade.sh

# Every 60 seconds.
echo "* * * * * root sh $PWD/upgrade.sh" >> /etc/crontab
