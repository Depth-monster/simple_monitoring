#!/usr/bin/env bash

set -Eeuo pipefail #strict-mode
IFS=$'\n\t'

PROC_NAME="test"
MON_URL="https://test.com/monitoring/test/api"
LOG_FILE="/var/log/monitoring.log"

pid="$(pgrep -xo "$PROC_NAME" || true)"

if [[ -n "$pid" ]]; then
  if ! curl --fail --silent --show-error --max-time 5 "$MON_URL" >/dev/null; then
    echo "$(date -Iseconds) monitoring unreachable: $MON_URL" >> "$LOG_FILE"
  fi

  STATE_DIR="/run/test-monitor"
  STATE_FILE="$STATE_DIR/last.start"
  mkdir -p "$STATE_DIR"

  start_time="$(awk '{print $22}' /proc/"$pid"/stat 2>/dev/null || echo 0)"
  last_time="$(cat "$STATE_FILE" 2>/dev/null || echo 0)"

  if [[ "$start_time" != "$last_time" ]]; then
    echo "$(date -Iseconds) $PROC_NAME restarted (pid $pid)" >> "$LOG_FILE"
  fi

  echo "$start_time" > "$STATE_FILE"
fi
