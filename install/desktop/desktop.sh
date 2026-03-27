#!/bin/sh
set -eu

. "$(dirname "$0")/../lib/helpers.sh"
install_exit_trap

for pkg in pulseaudio ffmpeg; do
    install_pkg_if_missing "$pkg"
done