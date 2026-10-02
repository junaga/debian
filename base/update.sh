set -eu

export DEBIAN_FRONTEND="noninteractive"
export NEEDRESTART_MODE="a"

apt update
apt full-upgrade --yes
deb-get update
deb-get upgrade --dg-only
pipx upgrade-all --global
# npm update can downgrade an installed package while min-release-age hides a newer release.
# Install only policy-eligible versions that are newer than the installed version.
npm_updates="$(npm outdated --global --json | node -e '
const outdated = JSON.parse(require("fs").readFileSync(0, "utf8"));
const semver = require("semver");
for (const [name, { current, wanted }] of Object.entries(outdated)) {
  if (semver.valid(current) && semver.valid(wanted) && semver.gt(wanted, current)) {
    console.log(`${name}@${wanted}`);
  }
}
')"
for npm_package in $npm_updates; do
  npm install --global --no-fund --allow-scripts=@railway/cli,esbuild,workerd "$npm_package"
done
