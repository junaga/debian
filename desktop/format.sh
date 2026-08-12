#!/bin/bash
set -e

test "$(findmnt -n -T / -o FSTYPE)" = btrfs
btrfs subvolume show /home >/dev/null 2>&1 || {
	test -z "$(find /home -mindepth 1 -print -quit)"
	rmdir /home
	btrfs subvolume create /home
}
btrfs property set /home compression zstd
