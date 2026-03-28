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
  podman-docker\
  npm\
    nodejs\
  git\
  ssh\
  curl\
    ca-certificates\
  ffmpeg\
  chromium;

# JavaScript CLI Dependencies
npm install\
  --global\
  --no-fund\
  \
  tsx\
  vite;

# AI Assistant
npm install\
  --global\
  --no-fund\
  \
  openclaw;

# Google Cloud CLI
mkdir -p $HOME/lib/ $HOME/bin/
curl -sSL https://sdk.cloud.google.com | bash -s -- --disable-prompts --install-dir=$HOME/lib
ln -sf $HOME/lib/google-cloud-sdk/bin/gcloud $HOME/bin/gcloud

# Editors and Monitors
apt install --yes\
  bash-completion\
  crudini\
  jq\
  pup\
  micro\
  \
  btop\
  lshw\
  ncdu\
  nyancat;
