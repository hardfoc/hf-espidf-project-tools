#!/usr/bin/env bash
# Canonical ESP-IDF flow: idf.py -C <project> -B <per-app build dir> -p <port> flash monitor
#
# Usage (from examples/esp32, after sourcing ESP-IDF export.sh):
#   export ESPPORT=/dev/ttyACM0
#   ./scripts/build_app.sh vortex_led_ws2812_smoke Release        # once, to create -B dir
#   ./scripts/idf_flash_monitor.sh vortex_led_ws2812_smoke Release
#
# Forward extra args to monitor (e.g. avoid DTR/RTS download strapping on some hosts):
#   ./scripts/idf_flash_monitor.sh vortex_led_ws2812_smoke Release --no-reset
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"
# shellcheck source=config_loader.sh
source "$SCRIPT_DIR/config_loader.sh"

APP_TYPE="${1:-vortex_led_ws2812_smoke}"
BUILD_TYPE="${2:-Release}"
MONITOR_ARGS=("${@:3}")

IDF_VERSION="$(get_idf_version_for_build_type "$APP_TYPE" "$BUILD_TYPE")"
TARGET="${IDF_TARGET:-$(get_target "$APP_TYPE")}"
export IDF_TARGET="$TARGET"

BUILD_DIR="$(get_build_directory "$APP_TYPE" "$BUILD_TYPE" "$TARGET" "$IDF_VERSION")"

if [[ ! -d "$BUILD_DIR" ]]; then
  echo "ERROR: Build directory not found: $BUILD_DIR" >&2
  echo "Run: ./scripts/build_app.sh $APP_TYPE $BUILD_TYPE" >&2
  exit 1
fi

if [[ -z "${ESPPORT:-}" ]]; then
  echo "ERROR: Set ESPPORT (e.g. export ESPPORT=/dev/ttyACM0)" >&2
  exit 1
fi

echo "=== idf.py flash monitor (native) ==="
echo "  -C $PROJECT_DIR"
echo "  -B $BUILD_DIR"
echo "  -p $ESPPORT"
echo "  app: $APP_TYPE  build: $BUILD_TYPE  idf: $IDF_VERSION  target: $TARGET"
echo "======================================"

exec idf.py -C "$PROJECT_DIR" -B "$BUILD_DIR" -p "$ESPPORT" flash monitor "${MONITOR_ARGS[@]}"
