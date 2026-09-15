#!/usr/bin/env bash
set -euo pipefail

(( EUID == 0 )) || {
	echo "run with sudo bash desktop/install-ssh.sh" >&2
	exit 1
}

apt-get install --yes openssh-server
sshd -t
systemctl enable --now ssh.service
