# Install shared system configuration and packages, then enable automatic updates.
# Run after installing Debian; elevates to root when needed.

set -eu
test $(whoami) != "root" && exec sudo -E sh $0
cd $(dirname $0)

export DEBIAN_FRONTEND="noninteractive"
export NEEDRESTART_SUSPEND="1"

# Modernize APT sources.
apt modernize-sources --assume-yes

# Bootstrap HTTPS
apt update
apt install --yes ca-certificates

# Install configuration
cp -r base/. /etc/

# Install packages
# Clear stale signed indexes.
rm -f /var/lib/apt/lists/*_InRelease
apt update
apt install --yes $(cat packages)

# Install deb-get
curl -L https://raw.githubusercontent.com/wimpysworld/deb-get/main/deb-get | bash -s install deb-get

# Install packages
deb-get install tailcat
pipx install --global huggingface_hub

npm install --global --no-fund @openai/codex
npm install --global --no-fund wrangler

# Update every two minutes
echo "*/2 * * * * root sh /etc/update.sh" >> /etc/crontab
