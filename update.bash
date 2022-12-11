[ "$(whoami)" == "root" ] || { echo "run with \`$ sudo bash -e \$FILE\`" >&2; exit 1; }

# https://www.debian.org/releases/
echo "===== Debian (\`apt\`) ====="
apt update
apt upgrade -y
apt autoremove -y

echo "===== Python (\`pip\`) ====="
for pkg in $(
  pip list --outdated --format=freeze \
  | grep -v '^\-e' \
  | cut -d "=" -f 1
); do
  pip install "$pkg"
done

echo "===== Node (\`npm\`) ====="
npm --global update

echo "===== Custom ====="
tldr --update
