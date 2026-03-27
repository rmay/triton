#!/bin/sh
# Exit immediately if a command exits with a non-zero status
set -e
IFS=$(printf ' \t\n')


TARGET_USER="$1"
TARGET_HOME="$2"

printf 'TARGET_USER=%s TARGET_HOME=%s\n' "$1" "$2"

case "$TARGET_HOME" in
  /*) : ;;
  *)  printf 'Error: TARGET_HOME must be an absolute path\n' >&2; exit 64 ;;
esac

[ -d "$TARGET_HOME" ] || { printf 'Error: home dir not found: %s\n' "$TARGET_HOME" >&2; exit 66; }


TRITON_INSTALL="$TARGET_HOME/.local/share/triton/install"

TTE=${TTE:-$(command -v tte 2>/dev/null || true)}

# Logging: tee all output to terminal and log file.
# Uses a named FIFO for POSIX sh compatibility (no process substitution).
# The log file is overwritten on each run; the FIFO is a temp pipe
# that must be recreated each run (stale ones from crashes are cleaned up).
LOG_FILE="/var/log/triton-install.log"
[ -p "${LOG_FILE}.fifo" ] && rm "${LOG_FILE}.fifo"
mkfifo "${LOG_FILE}.fifo"
tee "$LOG_FILE" < "${LOG_FILE}.fifo" &
exec > "${LOG_FILE}.fifo" 2>&1
ln -sf "$LOG_FILE" "${TARGET_HOME}/triton-install.log"
chown -h "${TARGET_USER}:${TARGET_USER}" "${TARGET_HOME}/triton-install.log"
printf '%60s\n' '' | tr ' ' '='
printf 'Triton install started: %s\n' "$(date)"
printf '%60s\n' '' | tr ' ' '='

# Give people a chance to retry running the installation
catch_errors() {
  status=$?
  rm -f "${LOG_FILE}.fifo"
  if [ "$status" -ne 0 ]; then
    printf '\n\033[31m%s\033[0m\n' "Triton installation failed!"
    printf '%s\n' "Retry: sh $TARGET_HOME/.local/share/triton/install.sh"
    printf '%s\n' "Get help from the community, if we had one."
    printf '%s\n' "Exit status: $status"
    printf '%s\n' "Log file: $LOG_FILE"
  fi
  exit "$status"
}
trap catch_errors EXIT
trap 'exit 130' INT TERM


show_logo() {
  [ -n "$TTE" ] || return 0
  command -v clear >/dev/null 2>&1 && clear || true
  "$TTE" -i "$TARGET_HOME/.local/share/triton/logo.txt" \
    --frame-rate "${2:-120}" \
    "${1:-expand}"
  printf '\n'
}

show_subtext() {
  text=$1
  mode=${2:-wipe}
  rate=${3:-640}
  if [ -n "$TTE" ]; then
    printf '%s\n' "$text" | "$TTE" --frame-rate "$rate" "$mode"
  else
    printf '%s\n' "$text"
  fi
  printf '\n'
}

# Runs a child script with timestamped start/done markers.
# A >>> without a matching <<< in the log means that script failed.
run_script() {
  _script=$1; shift
  _name=$(basename "$_script")
  printf '[%s] >>> %s\n' "$(date '+%H:%M:%S')" "$_name"
  sh "$_script" "$@"
  printf '[%s] <<< %s\n' "$(date '+%H:%M:%S')" "$_name"
}

run_script "$TRITON_INSTALL/preflight/pkgs.sh"
run_script "$TRITON_INSTALL/preflight/presentation.sh"

show_logo beams 240
show_subtext "Let's install Triton! [1/5]"
run_script "$TRITON_INSTALL/config/config.sh" "$TARGET_USER" "$TARGET_HOME"
run_script "$TRITON_INSTALL/config/networking.sh"

# Development
show_logo decrypt 920
show_subtext "Installing terminal tools [2/5]"
run_script "$TRITON_INSTALL/development/terminal.sh" "$TARGET_USER" "$TARGET_HOME"
run_script "$TRITON_INSTALL/development/development.sh"
run_script "$TRITON_INSTALL/development/nvim.sh" "$TARGET_USER" "$TARGET_HOME"
run_script "$TRITON_INSTALL/development/emacs.sh" "$TARGET_USER" "$TARGET_HOME"
run_script "$TRITON_INSTALL/development/ruby.sh" "$TARGET_USER"
run_script "$TRITON_INSTALL/development/golang.sh" "$TARGET_USER"
run_script "$TRITON_INSTALL/development/firewall.sh"
show_subtext "Finished terminal tools [2/5]"

# Desktop
show_logo slice 60
show_subtext "Installing desktop tools [3/5]"
run_script "$TRITON_INSTALL/desktop/x11.sh"
run_script "$TRITON_INSTALL/desktop/windowmaker.sh" "$TARGET_USER" "$TARGET_HOME"
run_script "$TRITON_INSTALL/desktop/fonts.sh" "$TARGET_USER" "$TARGET_HOME"
run_script "$TRITON_INSTALL/desktop/theme.sh" "$TARGET_USER" "$TARGET_HOME"
show_subtext "Finished desktop tools [3/6]"

# Window Maker settings
show_logo decrypt 920
show_subtext "Window Maker settings [4/5]"
run_script "$TRITON_INSTALL/desktop/windowmaker_settings.sh" "$TARGET_USER" "$TARGET_HOME"
run_script "$TRITON_INSTALL/apps/mimetypes.sh" "$TARGET_USER" "$TARGET_HOME"
show_subtext "Finished Window Maker settings [5/6]"

# Updates
show_logo highlight
show_subtext "Updating system packages [5/5]"
run_script "$TRITON_INSTALL/preflight/pkgs.sh"

# Final cleanup
chown -R "${TARGET_USER}:${TARGET_USER}" "$TARGET_HOME/.config/triton"

# Reboot
show_logo laseretch 920
show_subtext "You're done! Rebooting now..."
printf "End of script for now\n"
sleep 2
reboot
