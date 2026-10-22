#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFINES_FILE="$ROOT_DIR/dart_defines.json"

if [[ ! -f "$DEFINES_FILE" ]]; then
  echo "Missing $DEFINES_FILE" >&2
  echo "Copy dart_defines.json.example to dart_defines.json and set API_KEY." >&2
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

cd "$ROOT_DIR"
exec "${FLUTTER[@]}" "$@" --dart-define-from-file="$DEFINES_FILE"
