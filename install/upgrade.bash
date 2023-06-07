#!/bin/bash -e

if test $(whoami) != root
then
	echo "Error: run with \`$ sudo bash -e \$FILE\`" >&2
	exit 1
fi

dir="$(dirname "$(readlink -f "$0")")"

echo "===== Debian (\`apt\`) ====="
cp -r "$dir"/keyrings/ /etc/apt/keyrings/
cp "$dir"/sources.list /etc/apt/sources.list.d/invita.list

apt update
apt upgrade -y
apt install -y $(cat "$dir"/packages)
apt autoremove -y
apt update
apt install -y $(cat "$dir"/packages)
apt autoremove -y

echo "===== Node (\`npm\`) ====="
corepack enable \
	--install-directory /usr/local/bin/ \
	yarn pnpm
npm install --global tldr vite lighthouse
