apt update
apt upgrade --yes

DEBIAN_FRONTEND=noninteractive \
  apt install --yes --no-install-recommends \
    file \
    bsdextrautils \
    jq \
    unzip \
    bind9-dnsutils \
    wget \
    openssh-client \
    openssh-server \
    sshfs \
    xclip \
    \
    bash-completion \
    command-not-found \
    tree \
    htop \
    btop \
    ncdu \
    neofetch \
    \
    curl \
    imagemagick \
    ffmpeg \
    git \
    git-lfs \
    gh \
    docker.io \
    python3 \
    python3-pip \
    nodejs \
    npm \
    \
    cowsay \
    nyancat \
    cmatrix

# "command-not-found" initialization
# it uses the index of packages in apt (apt-cache),
# command-not-found needs the latest cache; to suggest what to install.
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

curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp > /usr/local/bin/yt-dlp
chmod +x /usr/local/bin/yt-dlp
yt-dlp --version
