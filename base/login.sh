#!/bin/bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
bash ./local-user.sh

# useradd allocates subordinate IDs for new users; preserve migrated mappings.
for mapping in /etc/subuid /etc/subgid; do
    if [ ! -r "$mapping" ] || ! grep -q '^local:' "$mapping"; then
        echo "local needs a non-overlapping subordinate-ID range in $mapping" >&2
        exit 1
    fi
done

runuser -u local -- env HOME=/home/local /bin/bash <<'EOF'
set -euo pipefail
umask 077
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    ssh-keygen -q -N "" -f "$HOME/.ssh/id_ed25519" -C "local@$(hostname)"
fi
chmod 600 "$HOME/.ssh/id_ed25519"
for private in config authorized_keys; do
    if [ -f "$HOME/.ssh/$private" ]; then chmod 600 "$HOME/.ssh/$private"; fi
done
if [ ! -f "$HOME/.ssh/id_ed25519.pub" ]; then
    ssh-keygen -y -f "$HOME/.ssh/id_ed25519" > "$HOME/.ssh/id_ed25519.pub"
fi
# Retain the existing Git author identity when migrating.
git config --global user.name >/dev/null || git config --global user.name local
git config --global user.email >/dev/null || git config --global user.email "local@$(hostname)"
EOF

# All virtual terminals start local; SSH authentication is unchanged.
LOCAL_LOGIN_SERVICE=/etc/systemd/system/getty@.service.d
install -d "$LOCAL_LOGIN_SERVICE"
cat > "$LOCAL_LOGIN_SERVICE/10-local.conf" <<'EOF'
[Service]
ExecStart=
ExecStart=-/usr/sbin/agetty --autologin local --noclear %I $TERM
EOF
# Remove overrides belonging to the retired split-user model.
rm -f /etc/systemd/system/getty@.service.d/10-junaga.conf \
    /etc/systemd/system/getty@tty2.service.d/20-hypr.conf
systemctl daemon-reload
