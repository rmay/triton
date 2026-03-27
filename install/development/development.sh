#!/bin/sh
set -eu

. "$(dirname "$0")/../lib/helpers.sh"
install_exit_trap

for pkg in \
  postgresql16-server \
  lazygit \
  rlwrap \
  ImageMagick7 \
  mise \
  autoconf \
  automake \
  libxslt \
  gmake \
  geany geany-plugins \
  zed-editor
do
  install_pkg_if_missing "$pkg"
done
