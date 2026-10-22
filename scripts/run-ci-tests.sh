#!/usr/bin/env bash
#
# Run the same checks as .github/workflows/flutter_dart.yml locally.
# Full output is written to logs/ci-local-<timestamp>.log for troubleshooting.
#
# Usage:
#   ./scripts/run-ci-tests.sh
#   ./scripts/run-ci-tests.sh --continue   # run all steps even after a failure
#
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$ROOT_DIR/logs"
CONTINUE_ON_FAIL=false

for arg in "$@"; do
  case "$arg" in
    --continue | -c)
      CONTINUE_ON_FAIL=true
      ;;
    -h | --help)
      sed -n '2,8p' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    *)
      echo "Unknown option: $arg (try --help)" >&2
      exit 2
      ;;
  esac
done

if command -v flutter >/dev/null 2>&1; then
  FLUTTER=(flutter)
elif [[ -x "$HOME/flutter/bin/flutter" ]]; then
  FLUTTER=("$HOME/flutter/bin/flutter")
else
  echo "Flutter not found on PATH or at ~/flutter/bin/flutter" >&2
  exit 1
fi

if command -v dart >/dev/null 2>&1; then
  DART=(dart)
else
  FLUTTER_BIN="$(dirname "$(command -v "${FLUTTER[0]}" 2>/dev/null || echo "$HOME/flutter/bin/flutter")")"
  if [[ -x "$FLUTTER_BIN/dart" ]]; then
    DART=("$FLUTTER_BIN/dart")
  else
    echo "dart not found on PATH or next to flutter ($FLUTTER_BIN/dart)" >&2
    exit 1
  fi
fi

mkdir -p "$LOG_DIR"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="$LOG_DIR/ci-local-${TIMESTAMP}.log"
LATEST_LINK="$LOG_DIR/ci-local-latest.log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== Local CI (flutter_dart.yml) ==="
echo "Started: $(date -Iseconds)"
echo "Log file: $LOG_FILE"
echo "Repository: $ROOT_DIR"
echo ""

cd "$ROOT_DIR"

echo "--- Environment ---"
uname -a || true
"${FLUTTER[@]}" --version
echo ""

FAILURES=()

run_step() {
  local name="$1"
  shift
  echo ""
  echo "========================================"
  echo "STEP: $name"
  echo "Command: $*"
  echo "========================================"
  if "$@"; then
    echo "RESULT: OK ($name)"
  else
    local code=$?
    echo "RESULT: FAILED ($name) exit code $code"
    FAILURES+=("$name (exit $code)")
    if [[ "$CONTINUE_ON_FAIL" == false ]]; then
      echo ""
      echo "Stopping after first failure (pass --continue to run remaining steps)."
      print_summary
      exit "$code"
    fi
    return "$code"
  fi
}

print_summary() {
  echo ""
  echo "=== Summary ==="
  echo "Finished: $(date -Iseconds)"
  if ((${#FAILURES[@]} == 0)); then
    echo "All steps passed."
  else
    echo "Failed steps (${#FAILURES[@]}):"
    for f in "${FAILURES[@]}"; do
      echo "  - $f"
    done
    echo ""
    echo "See full output in: $LOG_FILE"
  fi
}

if [[ -f .gitmodules ]]; then
  if git submodule status --recursive 2>/dev/null | grep -q '^[-+]'; then
    echo "NOTE: Git submodules are not fully initialized (CI uses submodules: recursive)."
    echo "      Run: git submodule update --init --recursive"
    echo ""
  fi
fi

run_step "Install dependencies" "${FLUTTER[@]}" pub get
run_step "Analyze code" "${FLUTTER[@]}" analyze --fatal-infos --fatal-warnings
run_step "Verify formatting" "${DART[@]}" format --output=none --set-exit-if-changed .
run_step "Run tests" "${FLUTTER[@]}" test -r github

print_summary

ln -sf "$(basename "$LOG_FILE")" "$LATEST_LINK"

if ((${#FAILURES[@]} > 0)); then
  exit 1
fi
