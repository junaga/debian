[ "$(whoami)" == "root" ] || { echo "run with \`$ sudo bash -e \$FILE\`" >&2; exit 1; }

# https://www.debian.org/releases/
echo "===== Debian (\`apt\`) ====="
apt update
apt upgrade -y
apt autoremove -y

echo "===== Python (\`pip\`) ====="
# shellcheck disable=SC2046
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
