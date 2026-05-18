#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

NODE_LOG_RUN_EPOCH="${NODE_LOG_RUN_EPOCH:-$(date +%s)}"
NODE_LOG_DATE="${NODE_LOG_DATE:-$(date -d "@$NODE_LOG_RUN_EPOCH" +%F)}"
NODE_LOG_ROOT="${NODE_LOG_ROOT:-$HOME/log}"
NODE_LOG_DAY_DIR="${NODE_LOG_DAY_DIR:-$NODE_LOG_ROOT/$NODE_LOG_DATE}"
NODE_LOG_LOCK="${NODE_LOG_LOCK:-$NODE_LOG_ROOT/goodnight.lock}"

function node_log_prepare_day {
	if ! mkdir -p "$NODE_LOG_ROOT" "$NODE_LOG_DAY_DIR"; then
		echo "node-log: cannot create $NODE_LOG_DAY_DIR; set NODE_LOG_ROOT to a writable path" >&2
		exit 1
	fi
}

function node_log_now {
	date --iso-8601=seconds
}

function node_log_checkpoint_last {
	if [ ! -f "$NODE_LOG_LOCK" ]; then
		echo 0
		return 0
	fi

	awk 'NF { last = $1 } END { if (last ~ /^[0-9]+$/) print last; else print 0 }' "$NODE_LOG_LOCK"
}

function node_log_checkpoint_append {
	local epoch="$1"
	printf '%s %s\n' "$epoch" "$(date --iso-8601=seconds -d "@$epoch")" >> "$NODE_LOG_LOCK"
}

function node_log_checkpoint_rollback {
	if [ ! -f "$NODE_LOG_LOCK" ]; then
		return 0
	fi

	local tmp
	tmp="$(mktemp "$NODE_LOG_ROOT/.goodnight-lock.XXXXXX")"
	awk 'NR > 1 { print prev } { prev = $0 }' "$NODE_LOG_LOCK" > "$tmp"
	cat "$tmp" > "$NODE_LOG_LOCK"
	rm -f "$tmp"
}

function node_log_section {
	local title="$1"
	printf "\n## %s\n\n" "$title"
}

function node_log_code_block {
	local language="${1:-text}"
	printf '```%s\n' "$language"
	cat
	printf '```\n'
}

function node_log_clip_lines {
	local limit="${1:-600}"
	awk -v limit="$limit" '{
		if (length($0) > limit) {
			print substr($0, 1, limit) "..."
		} else {
			print
		}
	}'
}
