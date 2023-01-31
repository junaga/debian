#!/bin/bash
# Update all software on my Debian system

if test "$(whoami)" != "root"
then
    echo "Error: run with \`$ sudo bash -e \$FILE\`" >&2
    exit 1
fi

echo "===== Debian (\`apt\`) ====="
# https://www.debian.org/releases/
apt update
apt upgrade -y
apt autoremove -y

echo "===== Python (\`pip\`) ====="
pip install $(pip list \
  --outdated --format=json \
  --disable-pip-version-check \
  |python3 -c "import json, sys; print(' '.join(
    [pkg['name'] for pkg in json.load(sys.stdin)]
  ))"
)

echo "===== Node (\`npm\`) ====="
npm --global update

echo "===== Custom ====="
tldr --update
