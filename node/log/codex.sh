#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

if [ "$#" -gt 1 ]; then
	echo "Usage: bash node/log/codex.sh [output.log]" >&2
	exit 2
fi

OUTPUT="${NODE_LOG_CODEX_OUTPUT:-${1:-./codex.log}}"
mkdir -p "$(dirname "$OUTPUT")"

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
CODEX_STATE_DB="${CODEX_STATE_DB:-$CODEX_HOME/state_5.sqlite}"
CODEX_HISTORY="${CODEX_HISTORY:-$CODEX_HOME/history.jsonl}"
CODEX_SESSIONS="${CODEX_SESSIONS:-$CODEX_HOME/sessions}"
CODEX_EXCERPT_CHARS="${NODE_LOG_CODEX_EXCERPT_CHARS:-1200}"

WINDOW_START="$(node_log_checkpoint_last)"
WINDOW_END="$NODE_LOG_RUN_EPOCH"

WINDOW_START_ISO="$(date --iso-8601=seconds -d "@$WINDOW_START")"
WINDOW_END_ISO="$(date --iso-8601=seconds -d "@$WINDOW_END")"

function codex_threads {
	if [ ! -f "$CODEX_STATE_DB" ] || ! command -v sqlite3 >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
		echo "No readable Codex state DB at $CODEX_STATE_DB."
		return 0
	fi

	sqlite3 -json "$CODEX_STATE_DB" "
		select
			datetime(created_at, 'unixepoch', 'localtime') as created_at,
			datetime(updated_at, 'unixepoch', 'localtime') as updated_at,
			id,
			cwd,
			title,
			rollout_path
		from threads
		where updated_at > $WINDOW_START and created_at <= $WINDOW_END
		order by updated_at asc;
	" | jq -r '.[] | "- \(.updated_at) `\(.id)` \(.title|@json)\n  cwd: \(.cwd)\n  rollout: \(.rollout_path)"'
}

function codex_rollout_files {
	if [ -f "$CODEX_STATE_DB" ] && command -v sqlite3 >/dev/null 2>&1; then
		sqlite3 -noheader "$CODEX_STATE_DB" "
			select rollout_path
			from threads
			where updated_at > $WINDOW_START and created_at <= $WINDOW_END
			  and rollout_path != ''
			order by updated_at asc;
		" | sort -u
		return 0
	fi

	if [ ! -d "$CODEX_SESSIONS" ]; then
		return 0
	fi

	find "$CODEX_SESSIONS" -type f -name "rollout-*.jsonl" -newermt "@$WINDOW_START" | sort
}

function summarize_rollout {
	local file="$1"
	local base
	base="$(basename "$file")"

	echo "## Session: $base"
	echo
	echo "- rollout: $file"
	echo "- bytes: $(wc -c < "$file")"
	echo "- lines: $(wc -l < "$file")"
	echo

	echo "### Session"
	echo
	jq -r '
		select((type == "object") and .type == "session_meta")
		| .payload
		| "- id: \(.id)\n- timestamp: \(.timestamp)\n- cwd: \(.cwd)\n- cli: \(.cli_version)\n- source: \(.source)\n- model_provider: \(.model_provider)"
	' "$file"
	jq -rs --argjson start "$WINDOW_START" --argjson end "$WINDOW_END" '
		def ts_epoch: (.timestamp | sub("\\.[0-9]+"; "") | fromdateiso8601);
		[
			.[] | select((type == "object") and (.timestamp? | type == "string") and (ts_epoch > $start and ts_epoch <= $end))
			| select(.type == "event_msg" and (.payload | type) == "object")
			| .payload.type as $type
			| select(["user_message", "agent_message", "task_complete", "context_compacted"] | index($type))
			| {timestamp, epoch: ts_epoch, type: .payload.type}
		]
		| sort_by(.epoch)
		| if length == 0 then
			"- status: no-events-in-window"
		  else
			.[-1] as $last
			| "- status: \(if $last.type == "task_complete" then "complete" else "open" end)\n- last_event: \($last.type) \($last.timestamp)"
		  end
	' "$file"
	echo

	echo "### TUI Timeline"
	echo
	jq -rs --argjson start "$WINDOW_START" --argjson end "$WINDOW_END" --argjson limit "$CODEX_EXCERPT_CHARS" '
		def ts_epoch: (.timestamp | sub("\\.[0-9]+"; "") | fromdateiso8601);
		def excerpt: tostring | gsub("[[:space:]]+"; " ") | .[0:$limit];
		def reasoning_text:
			(.payload.summary // [])
			| map(.text? // .summary_text? // .content? // empty)
			| join(" ")
			| excerpt;
		.[] | select((type == "object") and (.timestamp? | type == "string") and (ts_epoch > $start and ts_epoch <= $end))
		| if .type == "event_msg" and (.payload | type) == "object" then
			.payload as $p
			| if $p.type == "user_message" then
				"- USER: \(($p.message // "") | excerpt)"
			  elif $p.type == "agent_message" then
				"- ASSISTANT[\($p.phase // "message")]: \(($p.message // "") | excerpt)"
			  elif $p.type == "task_complete" then
				"- COMPLETE: duration_ms=\($p.duration_ms // "")"
			  elif $p.type == "context_compacted" then
				"- CONTEXT_COMPACTED"
			  else empty end
		  elif .type == "response_item" and (.payload | type) == "object" and .payload.type == "reasoning" and ((.payload.summary // []) | length > 0) then
			"- REASONING: \(reasoning_text)"
		  else empty end
	' "$file"
	echo

	echo "### Tool Summary"
	echo
	jq -r --argjson start "$WINDOW_START" --argjson end "$WINDOW_END" '
		def ts_epoch: (.timestamp | sub("\\.[0-9]+"; "") | fromdateiso8601);
		select((type == "object") and (.timestamp? | type == "string") and (ts_epoch > $start and ts_epoch <= $end))
		|
		select(.type == "response_item" and (.payload | type) == "object" and (.payload.type == "function_call" or .payload.type == "custom_tool_call"))
		| (.payload.name // .payload.tool_name // "custom_tool")
	' "$file" | sort | uniq -c | awk '{print "- " $2 ": " $1}'
	echo

	echo "### Command Count"
	echo
	jq -r --argjson start "$WINDOW_START" --argjson end "$WINDOW_END" '
		def ts_epoch: (.timestamp | sub("\\.[0-9]+"; "") | fromdateiso8601);
		def exe:
			(.payload.arguments // "{}" | fromjson? // {}) as $args
			| ($args.cmd // "")
			| gsub("^[[:space:]]+"; "")
			| split(" ")[0]
			| . // ""
			| if . == "" then "unknown" elif test("=") then "shell" else . end;
		select((type == "object") and (.timestamp? | type == "string") and (ts_epoch > $start and ts_epoch <= $end))
		| select(.type == "response_item" and (.payload | type) == "object" and .payload.type == "function_call" and .payload.name == "exec_command")
		| exe
	' "$file" | sort | uniq -c | sort -nr | awk '{print "- " $2 ": " $1}'
	echo

	echo "### Patch Summary"
	echo
	jq -rs --argjson start "$WINDOW_START" --argjson end "$WINDOW_END" --argjson limit "$CODEX_EXCERPT_CHARS" '
		def ts_epoch: (.timestamp | sub("\\.[0-9]+"; "") | fromdateiso8601);
		def excerpt: tostring | gsub("[[:space:]]+"; " ") | .[0:$limit];
		.[] | select((type == "object") and (.timestamp? | type == "string") and (ts_epoch > $start and ts_epoch <= $end))
		| select(.type == "event_msg" and (.payload | type) == "object" and .payload.type == "patch_apply_end")
		| (.payload.changes // {}) as $changes
		| ($changes | to_entries) as $entries
		| "- \(.timestamp) apply_patch success=\(.payload.success) files=\($entries | length) add=\($entries | map(select(.value.type == "add")) | length) update=\($entries | map(select(.value.type == "update")) | length) delete=\($entries | map(select(.value.type == "delete")) | length)\n  paths: \(($entries | map(.key) | join(", ")) | excerpt)"
		' "$file"
	echo
}

{
	echo "# Codex TUI Digest: $NODE_LOG_DATE"
	echo
	echo "- Codex home: $CODEX_HOME"
	echo "- Output: $OUTPUT"
	echo "- Checkpoint: $NODE_LOG_LOCK"
	echo
	echo "## Capture Window: $WINDOW_START_ISO to $WINDOW_END_ISO"
	echo
	echo "- Generated: $(node_log_now)"
	echo "- Lock: $NODE_LOG_LOCK"
	echo

	echo "### Threads"
	echo
	codex_threads
	echo

	echo "### Rollouts"
	echo
	codex_rollout_files | while read -r file; do
		[ -n "$file" ] || continue
		echo "- $file $(wc -c < "$file") bytes"
	done
	echo

	codex_rollout_files | while read -r file; do
		[ -n "$file" ] || continue
		summarize_rollout "$file"
	done
} > "$OUTPUT"

echo "$OUTPUT"
