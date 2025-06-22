apt update
apt upgrade --yes

DEBIAN_FRONTEND=noninteractive \
apt install --no-install-recommends --yes \
  bash-completion \
  command-not-found \
  file \
  tree \
  bsdextrautils \
  unzip \
  jq \
  bind9-dnsutils \
  wget \
  openssh-client \
  openssh-server \
  sshfs \
  git \
  git-lfs \
  \
  curl \
  ffmpeg \
  imagemagick \
  python3 \
  python3-pip \
  nodejs \
  npm \
  docker.io \
  gh \
  \
  htop \
  btop \
  ncdu \
  neofetch \
  \
  cowsay \
  nyancat \
  cmatrix

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
