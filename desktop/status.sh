#!/usr/bin/env bash
set -uo pipefail

LOG="$HOME/log/$(date +%F)/status.log"
mkdir -p "$(dirname "$LOG")"

{
	echo "# Desktop Status"
	echo
	echo "Generated: $(date --iso-8601=seconds)"
	echo "Host: $(hostname)"
	echo "User: $USER"
	echo "Window: current boot"
	echo "Log: $LOG"
	echo

	linux="$(journalctl -q -k -b -p warning..emerg --no-pager 2>&1 || true)"
	if [ -z "$linux" ]; then
		echo "PASS linux"
	else
		echo "FAIL linux"
		printf '%s\n' "$linux" | tail -40
	fi
	echo

	systemd_evidence=""

	system_state="$(systemctl is-system-running 2>&1 || true)"
	if [ "$system_state" != "running" ]; then
		systemd_evidence="${systemd_evidence}systemctl is-system-running:
$system_state

"
	fi

	failed_units="$(systemctl --failed --no-pager --plain 2>&1 || true)"
	failed_units="$(printf '%s\n' "$failed_units" | sed '/^UNIT LOAD ACTIVE SUB DESCRIPTION$/d; /^0 loaded units listed\.$/d; /^[[:space:]]*$/d')"
	if [ -n "$failed_units" ]; then
		systemd_evidence="${systemd_evidence}systemctl --failed:
$failed_units

"
	fi

	failed_user_units="$(systemctl --user --failed --no-pager --plain 2>&1 || true)"
	failed_user_units="$(printf '%s\n' "$failed_user_units" | sed '/^UNIT LOAD ACTIVE SUB DESCRIPTION$/d; /^0 loaded units listed\.$/d; /^[[:space:]]*$/d')"
	if [ -n "$failed_user_units" ]; then
		systemd_evidence="${systemd_evidence}systemctl --user --failed:
$failed_user_units

"
	fi

	system_journal="$(journalctl -q -b -p warning..emerg --no-pager 2>&1 || true)"
	if [ -n "$system_journal" ]; then
		systemd_evidence="${systemd_evidence}journalctl system warnings:
$(printf '%s\n' "$system_journal" | tail -40)

"
	fi

	user_journal="$(journalctl -q --user -b -p warning..emerg --no-pager 2>&1 || true)"
	if [ -n "$user_journal" ]; then
		systemd_evidence="${systemd_evidence}journalctl user warnings:
$(printf '%s\n' "$user_journal" | tail -40)

"
	fi

	if [ -z "$systemd_evidence" ]; then
		echo "PASS systemd"
	else
		echo "FAIL systemd"
		printf '%s' "$systemd_evidence" | sed '${/^[[:space:]]*$/d;}'
	fi
	echo

	hypr_evidence=""

	if ! command -v hyprctl >/dev/null 2>&1; then
		hypr_evidence="hyprctl: command not found
"
	else
		hypr_config="$(hyprctl configerrors 2>&1 || true)"
		if [ -n "$hypr_config" ]; then
			hypr_evidence="${hypr_evidence}hyprctl configerrors:
$hypr_config

"
		fi

		hypr_log="$(hyprctl rollinglog 2>&1 | grep -Ei 'warn|error|fail|critical|panic' || true)"
		if [ -n "$hypr_log" ]; then
			hypr_evidence="${hypr_evidence}hyprctl rollinglog warnings:
$(printf '%s\n' "$hypr_log" | tail -40)

"
		fi
	fi

	if [ -z "$hypr_evidence" ]; then
		echo "PASS hyprctl"
	else
		echo "FAIL hyprctl"
		printf '%s' "$hypr_evidence" | sed '${/^[[:space:]]*$/d;}'
	fi
} | tee "$LOG"

if grep -q '^FAIL ' "$LOG"; then
	exit 1
fi

exit 0
