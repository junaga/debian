#!/bin/bash
# Servers and desktops, not containers.
test "$FORCE" || test "$(systemd-detect-virt --container)" = none || {
	echo "Container detected; use FORCE=1."
	exit 0
}
set -e
DIR="$(dirname "$0")"

# Install package sources.
cp -ar "$DIR/etc/apt/." /etc/apt/.

# run upgrades at boot
echo '@reboot /bin/bash /usr/local/src/base/upgrade.sh' | crontab -
