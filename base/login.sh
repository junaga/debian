#!/bin/sh
set -e

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
