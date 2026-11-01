#!/usr/bin/env bash
# Poll for ESP32-class serial devices; log CONNECTED/DISCONNECTED on change.
# Run locally while plugging the board: ./scripts/watch_serial_port.sh
# Optional: LOG=/path/to.log ./scripts/watch_serial_port.sh

set -euo pipefail
LOG="${LOG:-/tmp/hf-vortex-esp-port-watch.log}"
INTERVAL_SEC="${INTERVAL_SEC:-2}"

ports_snapshot() {
  shopt -s nullglob
  local out=()
  local p
  for p in /dev/ttyACM* /dev/ttyUSB*; do out+=("$p"); done
  shopt -u nullglob
  if ((${#out[@]} == 0)); then echo ""; return; fi
  printf '%s ' "${out[@]}" | sed 's/[[:space:]]*$//'
}

PREV=""
echo "$(date -Is) watch_serial_port.sh started (interval ${INTERVAL_SEC}s) → $LOG" | tee -a "$LOG"
while true; do
  CUR="$(ports_snapshot)"
  if [[ "$CUR" != "$PREV" ]]; then
    if [[ -n "$CUR" ]]; then
      echo "$(date -Is) CONNECTED: $CUR" | tee -a "$LOG"
      echo "  hint: export ESPPORT=${CUR%% *}  # first port if multiple"
    else
      echo "$(date -Is) DISCONNECTED (no ttyACM/ttyUSB)" | tee -a "$LOG"
    fi
    PREV="$CUR"
  fi
  sleep "$INTERVAL_SEC"
done
