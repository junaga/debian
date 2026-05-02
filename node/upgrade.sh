# Update the version of the Debian config file
apt modernize-sources --yes

#====================================

CONFIG="/etc/apt/sources.list.d/debian.sources"
VERSION="testing"
# Debian Unstable is for dev testing
# Debian Testing is for main features
# Debian Stable is for release freezing
# Debian Oldstable is for legacy support

# Set Debian version
OLD_VERSION="$(lsb_release -cs)"
sed -i "s/$OLD_VERSION/$VERSION/g" $CONFIG
sed -i "s/$VERSION-updates//" $CONFIG
sed -i "s/$VERSION-backports//" $CONFIG

# Enable non open source packages
POLICY="main contrib non-free non-free-firmware"
sed -i "s/^Components:.*/Components: $POLICY/g" $CONFIG

# Patch
export DEBIAN_FRONTEND="noninteractive"
apt update --allow-releaseinfo-change
apt full-upgrade --yes

#====================================

# System Dependencies
apt install --yes\
  curl\
    ca-certificates\
  ffmpeg\
  ssh\
    kitty-terminfo\
  git\
  sqlite3\
  npm\
    nodejs\
  podman-docker\
  chromium\
  caddy;

# OpenAI Codex CLI
npm install --global @openai/codex

# common parser CLIs and editor TUIs
apt install --yes\
  rsync\
  ripgrep\
  crudini\
  jq\
  pup\
  \
  bash-completion\
  micro\
  btop\
  ncdu\
  lshw\
  nyancat;

# Google Cloud CLI
mkdir -p $HOME/lib/ $HOME/bin/
curl -sSL https://sdk.cloud.google.com | bash -s -- --disable-prompts --install-dir=$HOME/lib
ln -sf $HOME/lib/google-cloud-sdk/bin/gcloud $HOME/bin/gcloud

# Proton VPN for $1 a month
# https://account.protonvpn.com/downloads#wireguard-configuration
apt install --yes wireguard resolvconf
