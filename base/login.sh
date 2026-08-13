#!/usr/bin/env bash
# Configure console login behavior.
set -e

# Log in as root on virtual consoles for local recovery.
install -d /etc/systemd/system/getty@.service.d
printf '%s\n' \
  '[Service]' \
  'ExecStart=' \
  'ExecStart=-login -f root' \
  > /etc/systemd/system/getty@.service.d/override.conf
systemctl daemon-reload
