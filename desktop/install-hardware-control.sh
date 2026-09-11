#!/bin/bash
set -euo pipefail

cd -- "$(dirname -- "$0")"
(( EUID == 0 )) || { echo "run with sudo bash desktop/install-hardware-control.sh" >&2; exit 1; }

apt-get install --yes --no-install-recommends lm-sensors fancontrol

BOARD_VENDOR=$(cat /sys/devices/virtual/dmi/id/board_vendor 2>/dev/null || true)
BOARD_NAME=$(cat /sys/devices/virtual/dmi/id/board_name 2>/dev/null || true)

if [ "$BOARD_VENDOR" = "ASUSTeK COMPUTER INC." ] &&
	[ "$BOARD_NAME" = "PRIME Z370-P" ]; then
	echo "Detected ASUS PRIME Z370-P; building its board-gated WMI fan helper."
	if cmp -s ./etc/modules-load.d/nct6775.conf \
		/etc/modules-load.d/nct6775.conf 2>/dev/null; then
		rm -f /etc/modules-load.d/nct6775.conf
		echo "Removed the repository's conflicting nct6775 module-load entry."
	fi
	apt-get install --yes --no-install-recommends build-essential \
		"linux-headers-$(uname -r)"

	MODULE_SRC=./hardware/asus-fan
	BUILD_DIR=$(mktemp -d /tmp/asus-fan-build.XXXXXX)
	trap 'rm -rf "$BUILD_DIR"' EXIT
	cp "$MODULE_SRC"/{Makefile,protocol.h,protocol_test.c,asus_z370_wmi_control.c} \
		"$BUILD_DIR/"
	make -C "$BUILD_DIR" test
	make -C "$BUILD_DIR" modules

	install -d -m 0755 /usr/local/lib/asus-fan
	for SOURCE in Makefile README.md protocol.h protocol_test.c \
		asus_z370_wmi_control.c; do
		install -m 0644 "$MODULE_SRC/$SOURCE" \
			"/usr/local/lib/asus-fan/$SOURCE"
	done
	install -m 0644 "$BUILD_DIR/asus_z370_wmi_control.ko" \
		/usr/local/lib/asus-fan/asus_z370_wmi_control.ko
	install -m 0755 "$MODULE_SRC/asus-fan" /usr/local/bin/asus-fan
	echo "Installed /usr/local/bin/asus-fan; the installer does not load the module or change fan profiles."

else
	install -D -m 0644 ./etc/modules-load.d/nct6775.conf \
		/etc/modules-load.d/nct6775.conf
	echo "Installed nct6775 module-load configuration for a non-Z370 board."
fi

echo "Fan tools installed. The installer has not changed the current fan profile."
