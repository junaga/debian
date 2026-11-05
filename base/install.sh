# Install shared system configuration and packages, then enable automatic updates.
# Run after installing Debian; container skips automatic update registration.

set -eu
test "$(whoami)" != "root" && exec sudo -E sh "$0" "$@"
cd "$(dirname "$0")"

export DEBIAN_FRONTEND="noninteractive"
export NEEDRESTART_SUSPEND="1"

# Bootstrap HTTPS before modernizing APT sources.
apt update
apt install --yes ca-certificates
apt modernize-sources --assume-yes

# Install configuration
cp -r etc/. /etc/
set -a; . /etc/environment; set +a
rm -f /etc/skel/.bashrc /etc/skel/.bash_profile /etc/skel/.bash_login /etc/skel/.profile /etc/skel/.codex/AGENTS.md
rm -f /etc/skel/.config/git/config /etc/skel/.config/lesskey /etc/skel/.config/direnv/direnv.toml /etc/skel/.config/micro/settings.json /etc/skel/.config/micro/bindings.json
rm -f /etc/npmrc /etc/pip.conf

# Install packages
# Clear stale signed indexes.
rm -f /var/lib/apt/lists/*_InRelease
apt update
apt install --yes $(cat packages) tini

# Install deb-get
curl -L https://raw.githubusercontent.com/wimpysworld/deb-get/main/deb-get | bash -s install deb-get

# Install packages
deb-get install tailcat glab
curl -fL https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="/usr/bin" sh
UV_TOOL_DIR="/usr/lib/uv/tools" UV_TOOL_BIN_DIR="/usr/bin" uv tool install huggingface_hub

npm install --global --no-fund @openai/codex
npm install --global --no-fund --allow-scripts=agent-browser agent-browser
npm install --global --no-fund @pnp/cli-microsoft365
npm install --global --no-fund --allow-scripts=@stripe/cli @stripe/cli
npm install --global --no-fund --allow-scripts=@railway/cli @railway/cli
npm install --global --no-fund --allow-scripts=esbuild,workerd cf
npm install --global --prefix /usr --no-fund @cloudflare/speedtest@1.14.2 playwright-core@1.64.1
install -m 755 speedtest.mjs /usr/bin/cloudflare-speedtest

# Update every two minutes on hosts; rebuild containers to update packages.
test "${1-}" = "container" || echo '*/2 * * * * root . /etc/environment; sh "$REPO/base/upgrade.sh"' >> /etc/crontab
