set -e
cd "$(dirname "$0")"
BASE_PATH="/usr/local/src/base"

# Bootstrap HTTPS with the existing Debian source.
apt update
apt install --yes ca-certificates

# Install Base repositories.
cp -ar repo/. /etc/apt/sources.list.d/
rm -f /etc/apt/sources.list

# Configure Base.
sh "$BASE_PATH/upgrade.sh"

# Upgrade the system every 60 seconds.
echo "* * * * * root sh $BASE_PATH/upgrade.sh" >> /etc/crontab
