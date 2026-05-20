#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

node_log_prepare_day
export NODE_LOG_RUN_EPOCH NODE_LOG_DATE NODE_LOG_ROOT NODE_LOG_DAY_DIR NODE_LOG_LOCK

exec 9>>"$NODE_LOG_LOCK"
if command -v flock >/dev/null 2>&1; then
	if ! flock -n 9; then
		echo "goodnight.sh: another node log run holds $NODE_LOG_LOCK" >&2
		exit 75
	fi
else
	echo "goodnight.sh: flock command not found" >&2
	exit 127
fi

RUN="true"
case "${1:-}" in
	--run|"")
		RUN="true"
		[ "${1:-}" = "--run" ] && shift
		;;
	--no-run)
		RUN="false"
		shift
	;;
	*)
		echo "Usage: bash node/log/goodnight.sh [--run|--no-run]" >&2
		exit 2
		;;
esac

if [ "$#" -gt 0 ]; then
	echo "Usage: bash node/log/goodnight.sh [--run|--no-run]" >&2
	exit 2
fi

SYSTEM="$NODE_LOG_DAY_DIR/system.log"
CODEX="$NODE_LOG_DAY_DIR/codex.log"
REPORT="$NODE_LOG_DAY_DIR/goodnight.log"

if [ "$RUN" = "true" ] && [ -e "$REPORT" ]; then
	node_log_checkpoint_rollback
	rm -f "$SYSTEM" "$CODEX" "$REPORT"
else
	rm -f "$SYSTEM" "$CODEX"
fi

SYSTEM="$(NODE_LOG_SYSTEM_OUTPUT="$SYSTEM" bash "$SCRIPT_DIR/system.sh")"
CODEX="$(NODE_LOG_CODEX_OUTPUT="$CODEX" bash "$SCRIPT_DIR/codex.sh")"

function review_instructions {
	cat <<'PROMPT_HEAD'
You are reviewing one checkpoint of agent-mediated human and system operations for a Linux node.

Input is system.log followed by codex.log.

system.log is node health evidence. codex.log is a Codex TUI digest, not raw tool stdout/stderr.

Task: produce operational feedback and improvement proposals.

Rules:
- Be evidence-driven. Cite source file basenames, session IDs, or snapshot sections.
- Distinguish observed facts from inference.
- Review only the supplied input. Do not inspect raw ~/.codex logs, rollout JSONL, shell history, git history, browser history, screenshots, or desktop capture.
- Prefer concrete patches, scripts, docs, or config changes over generic advice.
- Do not recommend keylogging, screenshots, desktop video, browser history capture, or paid multimodal processing.
- Do not ask for command stdout/stderr, raw tool output, source diffs, or raw rollout JSONL unless the digest is clearly insufficient.
- Do not duplicate repo-local memory such as git history unless the day shows cross-system friction.
- If the source data is thin, say what should change in system.sh or codex.sh.

Return this exact shape:

1. Summary
2. What Actually Happened
3. Repeated Friction
4. System Risks
5. Human-Agent Workflow
6. Improvement Proposals
7. Tomorrow

Keep it short enough to read daily.
PROMPT_HEAD
}

if [ "$RUN" = "true" ]; then
	if ! command -v codex >/dev/null 2>&1; then
		echo "goodnight.sh: codex command not found" >&2
		exit 127
	fi

	{
		review_instructions
		echo
		cat "$SYSTEM"
		echo
		cat "$CODEX"
	} | codex exec --cd "$REPO_DIR" --sandbox read-only --ephemeral -o "$REPORT" -
	if [ ! -s "$REPORT" ]; then
		echo "goodnight.sh: report not written: $REPORT" >&2
		exit 1
	fi
	node_log_checkpoint_append "$NODE_LOG_RUN_EPOCH"
	echo "$REPORT"
else
	echo "$SYSTEM"
	echo "$CODEX"
	echo "Checkpoint not advanced: $NODE_LOG_LOCK"
	echo "Run review: bash node/log/goodnight.sh"
fi
