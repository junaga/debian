apt update
apt upgrade --yes
DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends --yes \
  bash-completion \
  command-not-found \
  file \
  jq \
  unzip \
  bsdextrautils \
  pulseaudio-utils \
  bind9-dnsutils \
  wget \
  openssh-client \
  openssh-server \
  sshfs \
  \
  curl \
  ffmpeg \
  imagemagick \
  git \
  git-lfs \
  gh \
  docker.io \
  python3 \
  python3-pip \
  nodejs \
  npm \
  \
  tree \
  htop \
  btop \
  ncdu \
  neofetch \
  \
  cowsay \
  nyancat \
  cmatrix

# "command-not-found" initialization (it needs a cache about the packages available in apt. command-not-found uses the latest cache to suggest what to install)
apt update

npm install --global --no-fund \
  vite \
  ts-node \
  typescript \
  prettier \
  npkill \
  \
	yarn \
  pnpm \
  bun

# get the latest version (not from apt)
curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
chmod +x /usr/local/bin/yt-dlp
yt-dlp --version
