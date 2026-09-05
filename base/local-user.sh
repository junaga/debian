#!/bin/bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
(( EUID == 0 )) || { echo "run as root" >&2; exit 1; }

# Refuse occupied IDs before changing either account database.
# Existing installations require the separate offline migration.
for kind in passwd group; do
    entry="$(getent "$kind" 1000 || true)"
    if [ -n "$entry" ] && [ "${entry%%:*}" != local ]; then
        echo "$kind ID 1000 is occupied; migrate first" >&2
        exit 1
    fi
done
if getent group local >/dev/null; then
    test "$(getent group local | cut -d: -f3)" = 1000
fi
if getent passwd local >/dev/null; then
    test "$(id -u local)" = 1000
    test "$(getent passwd local | cut -d: -f6)" = /home/local
fi
test ! -L /home/local || { echo "/home/local must not be a symlink" >&2; exit 1; }
visudo -cf etc/sudoers.d/local
if ! getent group local >/dev/null; then
    ! getent group 1000 >/dev/null || { echo "GID 1000 is occupied; migrate first" >&2; exit 1; }
    groupadd --gid 1000 local
fi
test "$(getent group local | cut -d: -f3)" = 1000
if ! getent passwd local >/dev/null; then
    ! getent passwd 1000 >/dev/null || { echo "UID 1000 is occupied; migrate first" >&2; exit 1; }
    useradd --uid 1000 --gid local --create-home --shell /bin/bash local
fi
test "$(id -u local)" = 1000
test "$(getent passwd local | cut -d: -f6)" = /home/local
usermod --gid local --append --groups sudo local
# SSH StrictModes also checks the home itself, not only .ssh.
mkdir -p /home/local
chown local:local /home/local
chmod go-w /home/local
install -d -m 0755 /etc/sudoers.d
install -m 0440 etc/sudoers.d/local /etc/sudoers.d/local
visudo -cf /etc/sudoers.d/local
# Preserve subordinate IDs in rootless container storage.
find /usr/local -xdev -uid 0 -exec chown -h local:local {} +
chmod g+rwx /usr/local
