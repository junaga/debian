# Debian Unstable is for dev testing
# Debian Testing is for main features
# Debian Stable is for release freezing
# Debian Oldstable is for legacy support

DEBIAN="testing"

# Update Debian config file version
apt modernize-sources --yes
CONFIG="/etc/apt/sources.list.d/debian.sources"

# Update Debian version
RELEASE="$(lsb_release -cs)"
sed -i "s/$RELEASE/$DEBIAN/g" $CONFIG
sed -i "s/$DEBIAN-updates//" $CONFIG
sed -i "s/$DEBIAN-backports//" $CONFIG

# Allow non open source packages
POLICY="main contrib non-free non-free-firmware"
sed -i "s/^Components:.*/Components: $POLICY/g" $CONFIG

# Patch
export DEBIAN_FRONTEND="noninteractive"
apt update --allow-releaseinfo-change
apt full-upgrade --yes

# System Dependencies
apt install --yes\
  curl\
    ca-certificates\
  ffmpeg\
  ssh\
    kitty-terminfo\
  git\
  npm\
    nodejs\
  podman-docker\
  chromium;

# Google Cloud CLI
mkdir -p $HOME/lib/ $HOME/bin/
curl -sSL https://sdk.cloud.google.com | bash -s -- --disable-prompts --install-dir=$HOME/lib
ln -sf $HOME/lib/google-cloud-sdk/bin/gcloud $HOME/bin/gcloud

# Parsers and Editors
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

# Proton VPN for $1 a month
# https://account.protonvpn.com/downloads#wireguard-configuration
apt install --yes wireguard resolvconf
