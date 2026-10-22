#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLUTTER_BIN="${FLUTTER_BIN:-$HOME/flutter/bin/flutter}"
DEFINES_FILE="${DEFINES_FILE:-$PROJECT_ROOT/dart_defines.json}"
ALLOW_DEBUG_SIGNING=false

if [[ "${1:-}" == "--allow-debug-signing" ]]; then
  ALLOW_DEBUG_SIGNING=true
  shift
fi

if [[ $# -ne 0 ]]; then
  echo "Usage: $0 [--allow-debug-signing]" >&2
  exit 2
fi

if [[ ! -x "$FLUTTER_BIN" ]]; then
  echo "Flutter executable not found: $FLUTTER_BIN" >&2
  echo "Set FLUTTER_BIN=/path/to/flutter/bin/flutter and retry." >&2
  exit 1
fi

if [[ ! -f "$DEFINES_FILE" ]]; then
  echo "Dart defines file not found: $DEFINES_FILE" >&2
  exit 1
fi

if [[ "$ALLOW_DEBUG_SIGNING" == false && ! -f "$PROJECT_ROOT/android/key.properties" ]]; then
  echo "android/key.properties is missing, so Gradle would use the debug key." >&2
  echo "Configure a release upload keystore, or use --allow-debug-signing for local testing." >&2
  exit 1
fi

cd "$PROJECT_ROOT"
"$FLUTTER_BIN" build appbundle \
  --release \
  --dart-define-from-file="$DEFINES_FILE"

SOURCE_AAB="$PROJECT_ROOT/build/app/outputs/bundle/release/app-release.aab"
if [[ ! -f "$SOURCE_AAB" ]]; then
  echo "Build completed but the expected bundle was not found: $SOURCE_AAB" >&2
  exit 1
fi

VERSION="$(sed -n 's/^version: *//p' pubspec.yaml | head -n 1)"
VERSION_NAME="${VERSION%%+*}"
VERSION_CODE="${VERSION##*+}"
OUTPUT_AAB="$PROJECT_ROOT/gulfcoastmesh-${VERSION_NAME}-build${VERSION_CODE}.aab"

cp "$SOURCE_AAB" "$OUTPUT_AAB"

if jarsigner -verify -certs "$OUTPUT_AAB" 2>&1 | grep -q 'CN=Android Debug'; then
  if [[ "$ALLOW_DEBUG_SIGNING" == false ]]; then
    echo "The bundle is debug-signed and is not suitable for Google Play." >&2
    exit 1
  fi
  OUTPUT_AAB="${OUTPUT_AAB%.aab}-debug-signed.aab"
  mv "$PROJECT_ROOT/gulfcoastmesh-${VERSION_NAME}-build${VERSION_CODE}.aab" "$OUTPUT_AAB"
  echo "WARNING: created a debug-signed bundle for local testing only." >&2
fi

echo "Created: $OUTPUT_AAB"
ls -lh "$OUTPUT_AAB"
