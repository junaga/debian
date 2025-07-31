# 1 debian apt
# ================
apt update
apt upgrade --yes
DEBIAN_FRONTEND=noninteractive \
apt install --no-install-recommends --yes \
  file \
  tree \
  bsdextrautils \
  jq \
  unzip \
  bind9-dnsutils \
  wget \
  openssh-client \
  openssh-server \
  sshfs \
  \
  curl \
  imagemagick \
  ffmpeg \
  python3 \
  pipx \
  nodejs \
  npm \
  git \
  gh \
  docker.io \
  \
  xclip \
  bash-completion \
  command-not-found \
  htop \
  btop \
  ncdu \
  neofetch \
  cowsay \
  nyancat

# "command-not-found" initialization
# it uses the index of packages in apt (apt-cache),
# command-not-found needs the latest cache; to suggest what to install.
apt update

# 2 python pip
# ================
PIPX_HOME="/usr/local/lib" \
PIPX_BIN_DIR="/usr/local/bin" \
PIPX_MAN_DIR="/usr/local/share/man" \
pipx install \
  terminaltexteffects

# 3 javascript npm
# ================
npm install --global --loglevel error --no-fund \
  vite \
  ts-node \
  typescript \
  prettier \
  npkill \
  \
  yarn \
  pnpm \
  bun

# 4 source
# ================
curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp > /usr/local/bin/yt-dlp
chmod +x /usr/local/bin/yt-dlp
yt-dlp --version
