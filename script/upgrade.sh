# 1 debian apt
# ================
apt update
apt upgrade --yes
DEBIAN_FRONTEND=noninteractive \
apt install --no-install-recommends --yes \
  gettext \
  file \
  tree \
  screen \
  bsdextrautils \
  jq \
  unzip \
  bind9-dnsutils \
  wget \
  openssh-client \
  openssh-server \
  sshpass \
  sshfs \
  \
  curl \
  imagemagick \
  ffmpeg \
  default-jre \
  python3 \
  pipx \
  nodejs \
  npm \
  git \
  gh \
  docker.io \
  \
  micro \
  xclip \
  bash-completion \
  command-not-found \
  htop \
  btop \
  ncdu \
  nyancat

# "command-not-found" initialization
# it uses the index of packages in apt (apt-cache),
# command-not-found needs the latest cache; to suggest what to install.
apt update

# 2 python pip
# ================
pipx_install() {
  PIPX_HOME="/usr/local/lib" \
  PIPX_BIN_DIR="/usr/local/bin" \
  PIPX_MAN_DIR="/usr/local/share/man" \
    pipx install "$@";
}
pipx_install terminaltexteffects
pipx_install sherlock-project
pipx_install mini-swe-agent

# 3 javascript npm
# ================
npm install --global --loglevel error --no-fund \
  vite@4 \
  ts-node \
  typescript \
  prettier \
  npkill \
  \
  yarn \
  pnpm \
  bun

# 4
# ================
LIB="/usr/local/lib"
BIN="/usr/local/bin"

# python3 zipimport binary
curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp > $BIN/yt-dlp
chmod +x $BIN/yt-dlp
yt-dlp --version

# java IzPack installer
curl -L https://software.verapdf.org/releases/verapdf-installer.zip > $LIB/verapdf.zip
unzip -q -d $LIB $LIB/verapdf.zip; rm $LIB/verapdf.zip
java -DINSTALL_PATH=$LIB/verapdf -jar $LIB/verapdf-*/verapdf-izpack-installer-*.jar -auto; rm -fr $LIB/verapdf-*
ln -sf $LIB/verapdf/verapdf      $BIN/verapdf
ln -sf $LIB/verapdf/verapdf-gui  $BIN/verapdf-gui
verapdf --version
