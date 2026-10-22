#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFINES_FILE="$ROOT_DIR/dart_defines.json"

# Prefer the local defines file for developer builds. CI and secret managers can
# provide MESHMAPPER_API_KEY without writing the key into the working tree.
BUILD_API_KEY="${MESHMAPPER_API_KEY:-${API_KEY:-}}"

if [[ -f "$DEFINES_FILE" ]]; then
  DART_DEFINE_ARGS=(--dart-define-from-file="$DEFINES_FILE")
elif [[ -n "$BUILD_API_KEY" ]]; then
  DART_DEFINE_ARGS=(--dart-define="API_KEY=${BUILD_API_KEY}")
else
  echo "Missing $DEFINES_FILE and no API key environment variable is set." >&2
  echo "Either copy dart_defines.json.example to dart_defines.json, or export MESHMAPPER_API_KEY." >&2
  exit 1
fi

if command -v flutter >/dev/null 2>&1; then
  FLUTTER=(flutter)
elif [[ -x "$HOME/flutter/bin/flutter" ]]; then
  FLUTTER=("$HOME/flutter/bin/flutter")
else
  echo "Flutter not found on PATH or at ~/flutter/bin/flutter" >&2
  exit 1
fi

if ! command -v adb >/dev/null 2>&1; then
  echo "adb not found on PATH" >&2
  exit 1
fi

cd "$ROOT_DIR"

echo "=== Building APK ==="
"${FLUTTER[@]}" build apk "${DART_DEFINE_ARGS[@]}"

APK_PATH="$ROOT_DIR/build/app/outputs/flutter-apk/app-release.apk"

if [[ ! -f "$APK_PATH" ]]; then
  echo "APK not found at $APK_PATH" >&2
  exit 1
fi

echo ""
echo "=== Checking ADB devices ==="
adb devices

echo ""
echo "=== Installing APK ==="
adb install -r "$APK_PATH"

echo ""
echo "=== Done ==="
echo "APK installed successfully."
