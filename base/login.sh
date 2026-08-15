set -e

# Local login
# ==============================================================================

# Autologin Linux virtual terminals.
LOCAL_LOGIN_SERVICE=/etc/systemd/system/getty@.service.d
mkdir -p "$LOCAL_LOGIN_SERVICE"
cat > "$LOCAL_LOGIN_SERVICE/override.conf" <<-EOF
	[Service]
	ExecStart=
	ExecStart=-login -f $USER
EOF

# Changes take effect after reboot.
systemctl daemon-reload

# Rootless containers
# ==============================================================================

# Containers need users and groups on the shared kernel.
grep -q "^$USER:" /etc/subuid || usermod --add-subuids 100000-165535 "$USER"
grep -q "^$USER:" /etc/subgid || usermod --add-subgids 100000-165535 "$USER"

# SSH identity
# ==============================================================================

# Create SSH keys if missing.
mkdir -p ~/.ssh
test -f ~/.ssh/id_ed25519 || ssh-keygen -q -N "" \
	-f ~/.ssh/id_ed25519 \
	-C "$USER@$HOSTNAME"

# Fix private-key permissions if migrated.
chmod 600 ~/.ssh/id_ed25519

# Recreate the public key if missing.
test -f ~/.ssh/id_ed25519.pub || ssh-keygen -y \
	-f ~/.ssh/id_ed25519 > ~/.ssh/id_ed25519.pub

# Print the public key.
cat ~/.ssh/id_ed25519.pub

# Git author
# ==============================================================================

git config --global user.name "$USER"
git config --global user.email "$USER@$HOSTNAME"
