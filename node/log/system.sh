#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

if [ "$#" -gt 1 ]; then
	echo "Usage: bash node/log/system.sh [output.log]" >&2
	exit 2
fi

SNAPSHOT="${NODE_LOG_SYSTEM_OUTPUT:-${1:-./system.log}}"
APT_LOG_LINES="${NODE_LOG_APT_LOG_LINES:-80}"
CODEX_LOG_LINES="${NODE_LOG_CODEX_LOG_LINES:-40}"
JOURNAL_LINES="${NODE_LOG_JOURNAL_LINES:-40}"
PACKAGE_LINES="${NODE_LOG_PACKAGE_LINES:-80}"
PROCESS_LINES="${NODE_LOG_PROCESS_LINES:-25}"
SYSTEMD_LINES="${NODE_LOG_SYSTEMD_LINES:-80}"
TEXT_LIMIT="${NODE_LOG_TEXT_LIMIT:-500}"

mkdir -p "$(dirname "$SNAPSHOT")"

SYSTEM_WINDOW_START="$(node_log_checkpoint_last)"
SYSTEM_WINDOW_START_ISO="$(date --iso-8601=seconds -d "@$SYSTEM_WINDOW_START")"
SYSTEM_WINDOW_END_ISO="$(date --iso-8601=seconds -d "@$NODE_LOG_RUN_EPOCH")"
SYSTEM_CODEX_LOG_START="$(date -u -d "@$SYSTEM_WINDOW_START" "+%Y-%m-%dT%H:%M:%S")"
SYSTEM_JOURNAL_SINCE="$(date -d "@$SYSTEM_WINDOW_START" "+%F %T")"

function node_log_if_command {
	command -v "$1" >/dev/null 2>&1
}

function node_log_missing_command {
	printf "%s: command not found\n" "$1"
}

{
	echo "# Node System Log: $NODE_LOG_DATE"
	echo
	echo "- Generated: $(node_log_now)"
	echo "- Host: $(hostname)"
	echo "- User: $USER"
	echo "- Repo: $REPO_DIR"
	echo "- Log: $SNAPSHOT"
	echo "- Since: $SYSTEM_WINDOW_START_ISO"
	echo "- Until: $SYSTEM_WINDOW_END_ISO"

	node_log_section "Node Identity"
	{
		uname -a
		uptime
		if node_log_if_command hostnamectl; then
			hostnamectl 2>/dev/null || true
		fi
		if node_log_if_command lsb_release; then
			lsb_release -a 2>/dev/null || true
		fi
	} | node_log_clip_lines "$TEXT_LIMIT" | node_log_code_block text

	node_log_section "Kernel"
	{
		uname -r
		printf "\n/proc/cmdline:\n"
		cat /proc/cmdline 2>/dev/null || true
		printf "\nInstalled module trees:\n"
		find /lib/modules -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | sort || true
		printf "\nBoot artifacts:\n"
		find /boot -maxdepth 1 -type f 2>/dev/null |
			sed 's#^.*/##' |
			grep -E '^(vmlinuz|initrd|config|System\.map)' |
			sort |
			tail -n 40 || true
	} | node_log_clip_lines "$TEXT_LIMIT" | node_log_code_block text

	node_log_section "CPU And Memory"
	{
		printf "nproc: "
		nproc 2>/dev/null || true
		if node_log_if_command lscpu; then
			lscpu | grep -E '^(Architecture|CPU\(s\)|Model name|Vendor ID|Virtualization):' || true
		fi
		printf "\n"
		free -h 2>/dev/null || vmstat -s 2>/dev/null || true
	} | node_log_clip_lines "$TEXT_LIMIT" | node_log_code_block text

	node_log_section "Storage"
	{
		df -h / "$HOME" /usr/local 2>/dev/null | awk 'NR == 1 || !seen[$6]++' || df -h
		printf "\nMounts:\n"
		for target in / "$HOME" /usr/local; do
			findmnt -rno TARGET,SOURCE,FSTYPE,OPTIONS "$target" 2>/dev/null || true
		done | sort -u || true
	} | node_log_clip_lines "$TEXT_LIMIT" | node_log_code_block text

	node_log_section "Drivers"
	{
		printf "Loaded graphics/storage/network modules:\n"
		lsmod 2>/dev/null |
			grep -Ei '^(nvidia|nouveau|amdgpu|i915|vfio|kvm|zfs|btrfs|ext4|xfs|nvme|ahci|e1000|igb|iwlwifi|r8169|r8125|btusb)\b' || true

		if node_log_if_command lspci; then
			printf "\nPCI kernel drivers:\n"
			lspci -nnk 2>/dev/null |
				grep -A3 -Ei 'vga|3d|display|ethernet|network|wireless|sata|nvme|raid|audio' || true
		fi

		if node_log_if_command nvidia-smi; then
			printf "\nNVIDIA SMI:\n"
			nvidia-smi 2>/dev/null || true
		fi
	} | node_log_clip_lines "$TEXT_LIMIT" | node_log_code_block text

	node_log_section "System Process Pressure"
	{
		process_snapshot="$(
			ps -eo user:32,pid,ppid,stat,pcpu,pmem,comm,args --sort=-pcpu |
			awk 'NR == 1 || $1 ~ /^(root|daemon|messagebus|systemd|polkitd|_apt|nobody|avahi|rtkit|uuidd|dnsmasq|postgres|mysql|redis|www-data|Debian-exim)$/' |
			head -n "$PROCESS_LINES" || true
		)"
		printf "%s\n" "$process_snapshot"
		if [ "$(printf "%s\n" "$process_snapshot" | wc -l)" -le 1 ]; then
			printf "\nNo system-owned processes are visible in this process namespace.\n"
		fi
	} | node_log_clip_lines "$TEXT_LIMIT" | node_log_code_block text

	if node_log_if_command systemctl; then
		node_log_section "Systemd Health"
		{
			printf "is-system-running: "
			systemctl is-system-running 2>&1 || true
			printf "\nFailed/degraded units:\n"
			systemctl list-units --state=failed,activating,deactivating,reloading --no-pager --plain 2>&1 |
				head -n "$SYSTEMD_LINES" || true
		} | node_log_clip_lines "$TEXT_LIMIT" | node_log_code_block text

		node_log_section "Systemd Failed Units"
		{
			systemctl --failed --no-pager 2>&1 || true
		} | node_log_clip_lines "$TEXT_LIMIT" | node_log_code_block text

		node_log_section "Systemd Timers"
		{
			systemctl list-timers --all --no-pager --plain 2>&1 |
				head -n "$SYSTEMD_LINES" || true
		} | node_log_clip_lines "$TEXT_LIMIT" | node_log_code_block text

		node_log_section "Systemd Sockets"
		{
			systemctl list-sockets --all --no-pager --plain 2>&1 |
				head -n "$SYSTEMD_LINES" || true
		} | node_log_clip_lines "$TEXT_LIMIT" | node_log_code_block text

		node_log_section "Systemd Enabled Units"
		{
			systemctl list-unit-files --type=service,socket,timer --state=enabled --no-pager --plain 2>&1 |
				head -n "$SYSTEMD_LINES" || true
		} | node_log_clip_lines "$TEXT_LIMIT" | node_log_code_block text

		node_log_section "Systemd User Failed Units"
		{
			systemctl --user --failed --no-pager 2>/dev/null || true
		} | node_log_clip_lines "$TEXT_LIMIT" | node_log_code_block text
	fi

	node_log_section "Package Manager Health"
	{
		printf "dpkg audit:\n"
		if node_log_if_command dpkg; then
			dpkg --audit 2>/dev/null || true
		else
			node_log_missing_command dpkg
		fi

		printf "\nnon-installed dpkg states:\n"
		if node_log_if_command dpkg-query; then
			dpkg-query -W -f='${db:Status-Abbrev} ${binary:Package} ${Version}\n' 2>/dev/null |
				awk '$1 !~ /^ii/ { print }' |
				head -n "$PACKAGE_LINES" || true
		else
			node_log_missing_command dpkg-query
		fi

		printf "\nheld packages:\n"
		if node_log_if_command apt-mark; then
			apt-mark showhold 2>/dev/null || true
		else
			node_log_missing_command apt-mark
		fi

		printf "\nupgradable packages:\n"
		if node_log_if_command apt; then
			apt list --upgradable 2>/dev/null |
				sed '/^Listing/d' |
				head -n "$PACKAGE_LINES" || true
		else
			node_log_missing_command apt
		fi

		printf "\nreboot required:\n"
		if [ -f /var/run/reboot-required ]; then
			cat /var/run/reboot-required 2>/dev/null || true
			if [ -f /var/run/reboot-required.pkgs ]; then
				cat /var/run/reboot-required.pkgs 2>/dev/null || true
			fi
		else
			echo "no"
		fi
	} | node_log_clip_lines "$TEXT_LIMIT" | node_log_code_block text

	node_log_section "APT Sources"
	{
		found_sources=0
		for apt_file in /etc/apt/sources.list /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources; do
			if [ -f "$apt_file" ]; then
				found_sources=1
				printf "%s:\n" "$apt_file"
				sed -E '/^[[:space:]]*(#|$)/d' "$apt_file" 2>/dev/null |
					head -n "$PACKAGE_LINES" || true
				printf "\n"
			fi
		done
		if [ "$found_sources" -eq 0 ]; then
			echo "no apt source files found"
		fi
	} | node_log_clip_lines "$TEXT_LIMIT" | node_log_code_block text

	node_log_section "APT Activity"
	{
		if [ -f /var/log/apt/history.log ]; then
			awk -v since="$SYSTEM_JOURNAL_SINCE" '
				/^Start-Date:/ {
					block = $0 "\n"
					ts = $0
					sub(/^Start-Date:[[:space:]]*/, "", ts)
					gsub(/[[:space:]]+/, " ", ts)
					keep = (ts >= since)
					next
				}
				block != "" {
					block = block $0 "\n"
					if (/^End-Date:/) {
						if (keep) {
							printf "%s\n", block
						}
						block = ""
						keep = 0
					}
				}
				END {
					if (keep && block != "") {
						printf "%s\n", block
					}
				}
			' /var/log/apt/history.log 2>/dev/null |
				tail -n "$APT_LOG_LINES" || true
		else
			echo "/var/log/apt/history.log: not found"
		fi
	} | node_log_clip_lines "$TEXT_LIMIT" | node_log_code_block text

	node_log_section "DPKG Activity"
	{
		if [ -f /var/log/dpkg.log ]; then
			awk -v since="$SYSTEM_JOURNAL_SINCE" '($1 " " $2) >= since { print }' /var/log/dpkg.log 2>/dev/null |
				tail -n "$APT_LOG_LINES" || true
		else
			echo "/var/log/dpkg.log: not found"
		fi
	} | node_log_clip_lines "$TEXT_LIMIT" | node_log_code_block text

	node_log_section "DKMS Health"
	{
		if node_log_if_command dkms; then
			dkms status 2>/dev/null || true
		else
			node_log_missing_command dkms
			printf "\n/var/lib/dkms:\n"
			find /var/lib/dkms -mindepth 1 -maxdepth 3 -type d -printf '%P\n' 2>/dev/null |
				sort |
				head -n "$PACKAGE_LINES" || true
		fi
	} | node_log_clip_lines "$TEXT_LIMIT" | node_log_code_block text

	if node_log_if_command ss; then
		node_log_section "Listening System Sockets"
		{
			ss -tulpen 2>/dev/null |
				head -n "$SYSTEMD_LINES" || true
		} | node_log_clip_lines "$TEXT_LIMIT" | node_log_code_block text
	fi

	if [ -f "$HOME/.codex/log/codex-tui.log" ]; then
		node_log_section "Codex Runtime Warnings"
		{
			awk -v since="$SYSTEM_CODEX_LOG_START" 'substr($0, 1, 19) >= since' "$HOME/.codex/log/codex-tui.log" 2>/dev/null |
				grep -Ei 'error|warn|failed|panic|timeout|denied' |
				tail -n "$CODEX_LOG_LINES" |
				node_log_clip_lines "$TEXT_LIMIT" || true
		} | node_log_code_block text
	fi

	if node_log_if_command journalctl; then
		node_log_section "Kernel Journal Warnings"
		{
			journalctl -k --since "$SYSTEM_JOURNAL_SINCE" -p warning..alert -n "$JOURNAL_LINES" --no-pager 2>/dev/null | node_log_clip_lines "$TEXT_LIMIT" || true
		} | node_log_code_block text

		node_log_section "System Journal Warnings"
		{
			journalctl --since "$SYSTEM_JOURNAL_SINCE" -p warning..alert -n "$JOURNAL_LINES" --no-pager 2>/dev/null | node_log_clip_lines "$TEXT_LIMIT" || true
		} | node_log_code_block text
	fi
} > "$SNAPSHOT"

echo "$SNAPSHOT"
