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

# migrate to NetworkManager
apt install --yes network-manager
crudini --set /etc/NetworkManager/NetworkManager.conf ifupdown managed true
nmcli connection migrate
systemctl restart NetworkManager
crudini --set /etc/NetworkManager/NetworkManager.conf main plugins keyfile
crudini --set /etc/NetworkManager/NetworkManager.conf main rc-manager file
systemctl stop 'ifup@*.service'
systemctl disable --now networking

# use Cloudflare DNS
nmcli -t -f UUID,TYPE connection show | while IFS=: read -r uuid type; do
	case "$type" in
	802-3-ethernet|802-11-wireless) nmcli connection modify "$uuid" \
		ipv4.ignore-auto-dns yes ipv6.ignore-auto-dns yes ipv4.dns 1.1.1.1,1.0.0.1 ;;
	esac
done
systemctl restart NetworkManager

# set author for git commits
git config --global user.name "$USER"
git config --global user.email "$USER@$HOSTNAME"
