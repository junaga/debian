# 1 Debian apt
# ================
DEBIAN_FRONTEND=noninteractive;
apt update;
apt upgrade --yes;
apt install --no-install-recommends --yes\
  gettext\
  file\
  tree\
  screen\
  sudo\
  bsdextrautils\
  jq\
  unzip\
  ca-certificates\
  bind9-dnsutils\
  wget\
  ssh\
  sshpass\
  sshfs\
  \
  lshw\
  bash-completion\
  command-not-found\
  micro\
  ncdu\
  btop\
  nyancat\
  \
  curl\
  imagemagick\
  ffmpeg\
  default-jre\
  python3\
  pipx\
  nodejs\
  npm\
  git\
  podman-docker;

# "command-not-found" initialization
# it uses the index of packages in apt (apt-cache),
# command-not-found needs the latest cache; to suggest what to install.
apt update;

# 2 Python pip
# ================
pip_install() {
  PIPX_HOME="/usr/local/lib"\
  PIPX_BIN_DIR="/usr/local/bin"\
  PIPX_MAN_DIR="/tmp"\
    pipx install "$@";
};

# pip_install sherlock-project
# pip_install terminaltexteffects

# 3 JavaScript npm
# ================
npm install --global --no-fund --loglevel error\
  @openai/codex\
  vite@4\
  prettier\
  npkill;

# 4 custom install
# ================
LIB="/usr/local/lib";
BIN="/usr/local/bin";

# python3 zipimport binary
curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp > $BIN/yt-dlp;
chmod +x $BIN/yt-dlp;
yt-dlp --version;
