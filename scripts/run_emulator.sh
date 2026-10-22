#!/usr/bin/env bash
# Launch an Android emulator and/or push a fresh build of the Gulf Coast Mesh app.
#
# Usage:
#   ./scripts/run_emulator.sh              # start emulator (if needed) + flutter run
#   ./scripts/run_emulator.sh start        # start emulator only (keep it running)
#   ./scripts/run_emulator.sh install      # rebuild APK, install, relaunch (emulator must be up)
#   ./scripts/run_emulator.sh phone        # same as default (flutter run)
#   ./scripts/run_emulator.sh tablet       # prefer a tablet AVD if one exists
#   ./scripts/run_emulator.sh physical     # use a USB-connected device
#   ./scripts/run_emulator.sh --list       # list AVDs and connected devices
#
# Extra args after the mode/device type are passed through to flutter, e.g.:
#   ./scripts/run_emulator.sh install --flavor whatever

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DEFINES_FILE="$PROJECT_DIR/dart_defines.json"
APP_ID="com.meshcore.gulf_coast_mesh_app"
MAIN_ACTIVITY="$APP_ID/.MainActivity"
MODE="${1:-phone}"
FLUTTER_EXTRA_ARGS=()

if [[ $# -gt 0 ]]; then
  shift
  FLUTTER_EXTRA_ARGS=("$@")
fi

cd "$PROJECT_DIR"

# --- Flutter ---
if command -v flutter >/dev/null 2>&1; then
  FLUTTER=(flutter)
elif [[ -x "$HOME/flutter/bin/flutter" ]]; then
  FLUTTER=("$HOME/flutter/bin/flutter")
else
  echo "Flutter not found on PATH or at ~/flutter/bin/flutter" >&2
  exit 1
fi

# --- Android SDK ---
if [[ -z "${ANDROID_HOME:-}" ]]; then
  if [[ -d "$HOME/Android/Sdk" ]]; then
    export ANDROID_HOME="$HOME/Android/Sdk"
  elif [[ -d "${ANDROID_SDK_ROOT:-}" ]]; then
    export ANDROID_HOME="$ANDROID_SDK_ROOT"
  fi
fi

if [[ -z "${ANDROID_HOME:-}" || ! -d "$ANDROID_HOME" ]]; then
  echo "Android SDK not found. Set ANDROID_HOME or install to ~/Android/Sdk" >&2
  exit 1
fi

export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"

if ! command -v adb >/dev/null 2>&1; then
  echo "adb not found under $ANDROID_HOME/platform-tools" >&2
  exit 1
fi

echo "Gulf Coast Mesh — emulator launcher"
echo "==================================="

list_and_exit() {
  echo "AVDs:"
  "${FLUTTER[@]}" emulators || true
  echo
  echo "Connected devices:"
  "${FLUTTER[@]}" devices || true
  exit 0
}

if [[ "$MODE" == "--list" || "$MODE" == "-l" ]]; then
  list_and_exit
fi

is_emulator_ready() {
  adb devices 2>/dev/null | grep -qE 'emulator-[0-9]+\s+device$'
}

get_running_emulator_id() {
  adb devices 2>/dev/null | grep -E 'emulator-[0-9]+\s+device$' | head -1 | awk '{print $1}'
}

get_physical_device_id() {
  "${FLUTTER[@]}" devices 2>/dev/null \
    | grep -E 'android-(arm|arm64|x64)' \
    | grep -vi emulator \
    | head -1 \
    | awk -F'•' '{print $2}' \
    | awk '{print $1}'
}

pick_avd_id() {
  local prefer="$1"
  local lines ids
  mapfile -t lines < <("${FLUTTER[@]}" emulators 2>/dev/null | grep '•' | grep -v '^Id')
  if [[ ${#lines[@]} -eq 0 ]]; then
    return 1
  fi

  ids=()
  local line id
  for line in "${lines[@]}"; do
    id="$(echo "$line" | awk -F'•' '{print $1}' | awk '{print $1}')"
    [[ -n "$id" ]] && ids+=("$id")
  done

  if [[ ${#ids[@]} -eq 0 ]]; then
    return 1
  fi

  if [[ "$prefer" == "tablet" ]]; then
    for id in "${ids[@]}"; do
      if echo "$id" | grep -qi 'tablet'; then
        echo "$id"
        return 0
      fi
    done
  fi

  if [[ "$prefer" == "phone" ]]; then
    for id in "${ids[@]}"; do
      if echo "$id" | grep -qi 'phone\|pixel\|medium'; then
        echo "$id"
        return 0
      fi
    done
  fi

  echo "${ids[0]}"
}

wait_for_emulator() {
  echo "Waiting for emulator to boot..." >&2
  adb wait-for-device

  local i=0
  local boot=""
  while (( i < 120 )); do
    boot="$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r' || true)"
    if [[ "$boot" == "1" ]] && is_emulator_ready; then
      echo "Emulator booted: $(get_running_emulator_id)" >&2
      sleep 2
      return 0
    fi
    i=$((i + 1))
    sleep 1
  done

  echo "Emulator boot timed out after 120s" >&2
  return 1
}

launch_emulator() {
  local kind="${1:-phone}"
  local avd
  local emulator_bin="$ANDROID_HOME/emulator/emulator"

  if is_emulator_ready; then
    echo "Emulator already running: $(get_running_emulator_id)" >&2
    return 0
  fi

  avd="$(pick_avd_id "$kind" || true)"
  if [[ -z "$avd" ]]; then
    echo "No Android Virtual Device found." >&2
    echo "Create one with: flutter emulators --create [--name Medium_Phone]" >&2
    return 1
  fi

  if [[ ! -x "$emulator_bin" ]]; then
    echo "Emulator binary not found at $emulator_bin" >&2
    return 1
  fi

  # Prefer host GPU + skip boot animation. Avoid flutter emulators --launch so we
  # can pass performance flags (important on hybrid Intel/NVIDIA hosts).
  echo "Starting AVD: $avd (host GPU, accelerated)" >&2
  "$emulator_bin" \
    -avd "$avd" \
    -gpu host \
    -accel on \
    -no-boot-anim \
    -no-audio \
    -no-snapshot-save \
    >/dev/null 2>&1 &
  wait_for_emulator
}

# Prints only the device id on stdout; status goes to stderr.
resolve_emulator_device() {
  local kind="${1:-phone}"
  if is_emulator_ready; then
    get_running_emulator_id
    return 0
  fi
  if launch_emulator "$kind"; then
    get_running_emulator_id
    return 0
  fi
  return 1
}

append_defines() {
  local -n _args=$1
  if [[ -f "$DEFINES_FILE" ]]; then
    _args+=(--dart-define-from-file="$DEFINES_FILE")
    echo "Using dart defines from $DEFINES_FILE"
  else
    echo "Note: $DEFINES_FILE not found (optional). Copy dart_defines.json.example if you need API keys."
  fi
}

# Impeller can be forced on via --enable-impeller; keep default Skia on Android
# emulators and avoid software rendering. Extra flutter-run-only flags live here.
append_emulator_flutter_flags() {
  local -n _args=$1
  local device_id="$2"
  if [[ "$device_id" == emulator-* ]]; then
    # Explicitly disable Impeller if a future Flutter defaults it on for Android.
    _args+=(--no-enable-impeller)
  fi
}

install_and_launch() {
  local device_id="$1"
  # flutter install does not accept --dart-define-from-file; build first, then install
  # the binary. Debug is what you want for iteration (install alone defaults to release).
  local apk_path="$PROJECT_DIR/build/app/outputs/flutter-apk/app-debug.apk"
  local build_args=(build apk --debug)
  local install_args=(
    install --debug
    -d "$device_id"
    --use-application-binary="$apk_path"
  )

  append_defines build_args
  if [[ ${#FLUTTER_EXTRA_ARGS[@]} -gt 0 ]]; then
    build_args+=("${FLUTTER_EXTRA_ARGS[@]}")
  fi

  echo
  echo "Rebuilding debug APK & installing on: $device_id"
  "${FLUTTER[@]}" "${build_args[@]}"
  "${FLUTTER[@]}" "${install_args[@]}"

  echo "Launching $APP_ID..."
  adb -s "$device_id" shell am force-stop "$APP_ID" >/dev/null 2>&1 || true
  adb -s "$device_id" shell am start -n "$MAIN_ACTIVITY" >/dev/null
  echo "Done. Emulator left running — run again anytime with: ./scripts/run_emulator.sh install"
}

DEVICE_ID=""

case "$MODE" in
  start)
    echo "Starting emulator only (no app install)..."
    if ! resolve_emulator_device phone >/dev/null; then
      echo "Failed to start emulator." >&2
      exit 1
    fi
    DEVICE_ID="$(get_running_emulator_id)"
    echo
    echo "Emulator ready: $DEVICE_ID"
    echo "Rebuild/install later with: ./scripts/run_emulator.sh install"
    echo "Or use Cursor task: \"Rebuild & install on emulator\""
    exit 0
    ;;

  install|rebuild|reload)
    echo "Looking for a running emulator..."
    if ! is_emulator_ready; then
      echo "No emulator is running." >&2
      echo "Start one with: ./scripts/run_emulator.sh start" >&2
      exit 1
    fi
    DEVICE_ID="$(get_running_emulator_id)"
    install_and_launch "$DEVICE_ID"
    exit 0
    ;;

  physical)
    echo "Looking for a physical Android device..."
    DEVICE_ID="$(get_physical_device_id || true)"
    if [[ -z "$DEVICE_ID" ]]; then
      echo "No physical Android device found." >&2
      "${FLUTTER[@]}" devices || true
      exit 1
    fi
    ;;

  phone|tablet)
    echo "Looking for an Android emulator ($MODE)..."
    DEVICE_ID="$(resolve_emulator_device "$MODE" || true)"

    if [[ -z "${DEVICE_ID:-}" ]]; then
      PHYSICAL="$(get_physical_device_id || true)"
      if [[ -n "$PHYSICAL" ]]; then
        echo "Could not start emulator; physical device available: $PHYSICAL"
        if [[ -t 0 ]]; then
          read -r -p "Run on physical device instead? [y/N] " reply
          if [[ "$reply" =~ ^[Yy]$ ]]; then
            DEVICE_ID="$PHYSICAL"
          else
            exit 1
          fi
        else
          echo "Non-interactive shell; refusing to fall back automatically." >&2
          exit 1
        fi
      else
        echo "No emulator or physical device available." >&2
        "${FLUTTER[@]}" devices || true
        exit 1
      fi
    else
      echo "Using emulator: $DEVICE_ID"
    fi
    ;;

  *)
    echo "Unknown mode: $MODE" >&2
    echo "Usage: $0 [start|install|phone|tablet|physical|--list] [flutter args...]" >&2
    exit 1
    ;;
esac

if [[ -z "${DEVICE_ID:-}" ]]; then
  echo "No device selected." >&2
  exit 1
fi

RUN_ARGS=(run -d "$DEVICE_ID")
append_defines RUN_ARGS
append_emulator_flutter_flags RUN_ARGS "$DEVICE_ID"
if [[ ${#FLUTTER_EXTRA_ARGS[@]} -gt 0 ]]; then
  RUN_ARGS+=("${FLUTTER_EXTRA_ARGS[@]}")
fi

echo
echo "Running app on: $DEVICE_ID (attached flutter run session)"
echo "Tip: keep the emulator up and use ./scripts/run_emulator.sh install for quick rebuilds."
echo

exec "${FLUTTER[@]}" "${RUN_ARGS[@]}"
