#!/bin/sh
# Shared helper functions for Triton install scripts.
# Source this file: . "$(dirname "$0")/../lib/helpers.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default log file — individual scripts may override this before sourcing.
: "${LOG_FILE:=/var/log/triton-install.log}"

_log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOG_FILE"
}

print_status() {
  printf '%b[INFO]%b [%s] %s\n' "$BLUE" "$NC" "$(date '+%H:%M:%S')" "$1"
  _log "INFO    $1"
}

print_success() {
  printf '%b[SUCCESS]%b [%s] %s\n' "$GREEN" "$NC" "$(date '+%H:%M:%S')" "$1"
  _log "SUCCESS $1"
}

print_warning() {
  printf '%b[WARNING]%b [%s] %s\n' "$YELLOW" "$NC" "$(date '+%H:%M:%S')" "$1"
  _log "WARNING $1"
}

print_error() {
  printf '%b[ERROR]%b [%s] %s\n' "$RED" "$NC" "$(date '+%H:%M:%S')" "$1"
  _log "ERROR   $1"
}

# Install a package if not already present. Failures are non-fatal (warning only)
# so a missing package in one repo doesn't abort the rest of the install.
install_pkg_if_missing() {
  _pkg=$1
  if pkg info -e "$_pkg" >/dev/null 2>&1; then
    return 0
  fi
  print_status "Installing ${_pkg}..."
  if pkg install -y "$_pkg"; then
    print_success "${_pkg} installed"
  else
    print_warning "Failed to install ${_pkg} — skipping"
  fi
}

# Sets EXIT and ERR traps that report the script name, failing line, and exit
# code on failure.  FreeBSD sh supports ERR traps; the ERR trap records the
# line number of the failing command so the EXIT trap can report it.
# Call once, immediately after sourcing this file.
install_exit_trap() {
  _TRITON_FAIL_LINE=0
  # ERR fires on every failing command while set -e is active.
  # Suppress the trap assignment itself if the shell doesn't support ERR.
  trap '_TRITON_FAIL_LINE=$LINENO' ERR 2>/dev/null || true
  trap '_st=$?
    if [ "$_st" -ne 0 ]; then
      print_error "$(basename "$0") failed at line ${_TRITON_FAIL_LINE} (exit ${_st})"
    fi
    exit "$_st"' EXIT
}
