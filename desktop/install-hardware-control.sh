#!/bin/bash
set -euo pipefail

cd -- "$(dirname -- "$0")"
(( EUID == 0 )) || { echo "run with sudo bash desktop/install-hardware-control.sh" >&2; exit 1; }

apt-get install --yes --no-install-recommends lm-sensors fancontrol
install -D -m 0644 ./etc/modules-load.d/nct6775.conf /etc/modules-load.d/nct6775.conf

echo "Fan tools installed; nct6775 requested at boot. No fan curve has been configured."
