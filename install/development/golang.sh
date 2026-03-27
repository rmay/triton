#!/bin/sh
set -eu

. "$(dirname "$0")/../lib/helpers.sh"
install_exit_trap

# Install Go via pkg — FreeBSD-native binary, no version manager needed.
install_pkg_if_missing go
