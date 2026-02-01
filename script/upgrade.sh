# 1 debian apt
# ================
apt update
DEBIAN_FRONTEND=noninteractive \
apt upgrade --yes
DEBIAN_FRONTEND=noninteractive \
apt install --no-install-recommends --yes \
  gettext \
  file \
  tree \
  screen \
  sudo \
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
  bash-completion \
  command-not-found \
  micro \
  btop \
  ncdu \
  nyancat \
  \
  ca-certificates \
  curl \
  imagemagick \
  ffmpeg \
  default-jre \
  python3 \
  pipx \
  nodejs \
  npm \
  git \
  docker.io

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

pipx_install sherlock-project
# pipx_install terminaltexteffects

# 3 javascript npm
# ================
npm install --global --loglevel error --no-fund \
  @openai/codex \
  vite@4 \
  prettier \
  npkill

# 4 others
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
