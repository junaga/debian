#!/bin/bash
set -euo pipefail

(( EUID == 0 )) || {
	echo "run with sudo bash desktop/install-hardware-control.sh" >&2
	exit 1
}

apt-get install --yes --no-install-recommends lm-sensors fancontrol
echo "Installed lm-sensors and fancontrol; no fan profile was changed."
