#!/usr/bin/env bash
# Build the Gulf Coast Mesh app for a desktop target.
#
# Usage:
#   ./scripts/build_desktop.sh                       # Linux release (default)
#   ./scripts/build_desktop.sh linux                 # Linux release
#   ./scripts/build_desktop.sh macos                 # macOS release
#   ./scripts/build_desktop.sh windows               # Windows release
#   ./scripts/build_desktop.sh linux --debug         # Pass options to flutter build

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TARGET="${1:-linux}"

case "$TARGET" in
  linux|macos|windows)
    if [[ $# -gt 0 ]]; then
      shift
    fi
    ;;
  *)
    echo "Unsupported desktop target: $TARGET" >&2
    echo "Choose linux, macos, or windows." >&2
    exit 2
    ;;
esac

if command -v flutter >/dev/null 2>&1; then
  FLUTTER=(flutter)
elif [[ -x "$HOME/flutter/bin/flutter" ]]; then
  FLUTTER=("$HOME/flutter/bin/flutter")
else
  echo "Flutter not found on PATH or at ~/flutter/bin/flutter" >&2
  exit 1
fi

BUILD_MODE=release
ADD_DEFAULT_MODE=true
for argument in "$@"; do
  case "$argument" in
    --debug)
      BUILD_MODE=debug
      ADD_DEFAULT_MODE=false
      break
      ;;
    --profile)
      BUILD_MODE=profile
      ADD_DEFAULT_MODE=false
      break
      ;;
    --release)
      BUILD_MODE=release
      ADD_DEFAULT_MODE=false
      break
      ;;
  esac
done

BUILD_ARGS=(build "$TARGET")
if [[ "$ADD_DEFAULT_MODE" == true ]]; then
  BUILD_ARGS+=(--release)
fi

DEFINES_FILE="$PROJECT_DIR/dart_defines.json"
if [[ -f "$DEFINES_FILE" ]]; then
  BUILD_ARGS+=(--dart-define-from-file="$DEFINES_FILE")
fi
BUILD_ARGS+=("$@")

cd "$PROJECT_DIR"
echo "Building Gulf Coast Mesh for $TARGET..."
"${FLUTTER[@]}" "${BUILD_ARGS[@]}"

case "$TARGET" in
  linux)
    OUTPUT="$PROJECT_DIR/build/linux/x64/$BUILD_MODE/bundle"
    ;;
  macos)
    case "$BUILD_MODE" in
      debug) CONFIGURATION=Debug ;;
      profile) CONFIGURATION=Profile ;;
      release) CONFIGURATION=Release ;;
    esac
    OUTPUT="$PROJECT_DIR/build/macos/Build/Products/$CONFIGURATION"
    ;;
  windows)
    case "$BUILD_MODE" in
      debug) CONFIGURATION=Debug ;;
      profile) CONFIGURATION=Profile ;;
      release) CONFIGURATION=Release ;;
    esac
    OUTPUT="$PROJECT_DIR/build/windows/x64/runner/$CONFIGURATION"
    ;;
esac

echo "Desktop build complete: $OUTPUT"
