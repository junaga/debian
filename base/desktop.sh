#!/bin/sh
# Current account: sh "$REPO/base/desktop.sh"
# Switch accounts: sh "$REPO/base/desktop.sh" 1000
[ "$#" -eq 0 ] || exec run0 --pipe -u "$1" --setenv="WORK=${WORK-}" \
    --setenv="REPO=${REPO-}" /bin/sh "$(realpath "$0")"
set -a
. "$HOME/.env"
set +a
systemd-cat -t desktop-health "$AGENT" exec -C "${REPO:-$WORK/src}" "Run DHC." </dev/null &
exec systemd-cat -t labwc-session "${DESKTOP:-/usr/libexec/labwc-session}"
