#!/usr/bin/env bash
# Launch the Gulf Coast Mesh app on a desktop target.
#
# Usage:
#   ./scripts/run_desktop.sh                         # Linux (default)
#   ./scripts/run_desktop.sh linux                   # Linux
#   ./scripts/run_desktop.sh macos                  # macOS
#   ./scripts/run_desktop.sh windows                # Windows
#   ./scripts/run_desktop.sh --list                 # List available devices
#   ./scripts/run_desktop.sh linux --profile        # Pass args to flutter run

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TARGET="${1:-linux}"

if [[ $# -gt 0 ]]; then
  shift
fi

if command -v flutter >/dev/null 2>&1; then
  FLUTTER=(flutter)
elif [[ -x "$HOME/flutter/bin/flutter" ]]; then
  FLUTTER=("$HOME/flutter/bin/flutter")
else
  echo "Flutter not found on PATH or at ~/flutter/bin/flutter" >&2
  exit 1
fi

cd "$PROJECT_DIR"

if [[ "$TARGET" == "--list" || "$TARGET" == "-l" ]]; then
  exec "${FLUTTER[@]}" devices
fi

case "$TARGET" in
  linux|macos|windows)
    ;;
  *)
    echo "Unsupported desktop target: $TARGET" >&2
    echo "Choose linux, macos, or windows." >&2
    exit 2
    ;;
esac

RUN_ARGS=(run -d "$TARGET")
DEFINES_FILE="$PROJECT_DIR/dart_defines.json"
if [[ -f "$DEFINES_FILE" ]]; then
  RUN_ARGS+=(--dart-define-from-file="$DEFINES_FILE")
fi
RUN_ARGS+=("$@")

echo "Running Gulf Coast Mesh on $TARGET..."
exec "${FLUTTER[@]}" "${RUN_ARGS[@]}"
