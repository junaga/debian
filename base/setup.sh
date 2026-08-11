# Servers and desktops, not containers.
test "$FORCE" || test "$(systemd-detect-virt --container)" = none || {
	echo "Container detected; use FORCE=1."
	exit 0
}
set -e

# run upgrades at boot
echo '@reboot /bin/bash /usr/local/src/base/upgrade.sh' | crontab -

# migrate to NetworkManager
sudo apt install --yes network-manager
sudo crudini --set /etc/NetworkManager/NetworkManager.conf ifupdown managed true
sudo nmcli connection migrate
sudo systemctl restart NetworkManager
sudo crudini --set /etc/NetworkManager/NetworkManager.conf main plugins keyfile
sudo crudini --set /etc/NetworkManager/NetworkManager.conf main rc-manager file
sudo systemctl stop 'ifup@*.service'
sudo systemctl disable --now networking

# use Cloudflare DNS
nmcli -t -f UUID,TYPE connection show | while IFS=: read -r uuid type; do
	case "$type" in
	802-3-ethernet|802-11-wireless) sudo nmcli connection modify "$uuid" \
		ipv4.ignore-auto-dns yes ipv6.ignore-auto-dns yes ipv4.dns 1.1.1.1,1.0.0.1 ;;
	esac
done
sudo systemctl restart NetworkManager

# autologin Linux terminals
sudo systemctl edit getty@.service --stdin <<-EOF
	[Service]
	ExecStart=
	ExecStart=-login -f $USER
EOF

# input $EMAIL
echo "The email labels your SSH public key for simpler management."
echo "Your GitHub email links pushed Git commits to your profile for attribution."
read -e -i "$USER@$HOSTNAME" -p "Email: " EMAIL

# generate SSH key
mkdir -p ~/.ssh
ssh-keygen -q -N "" \
	-f ~/.ssh/id_ed25519 \
	-C "$EMAIL" || true

# enable SSH forwarding
systemctl --user enable --now ssh-agent.socket

# set author for git commits
git config --global user.name "$USER"
git config --global user.email "$EMAIL"

# output $SSH_PUBLIC_KEY
echo ============================
echo "Copy this SSH public key to remote systems for authentication:"
cat ~/.ssh/id_ed25519.pub
echo ============================

# expose administrator-owned applications and data in the local hierarchy
sudo install -d -o root -g root -m 0755 /opt /srv
sudo ln -sfnT /opt /usr/local/app
sudo ln -sfnT /srv /usr/local/var
