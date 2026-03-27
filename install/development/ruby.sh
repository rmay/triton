#!/bin/sh
set -eu

TARGET_USER="$1"

# Build dependencies required to compile Ruby from source via mise/ruby-build.
# libyaml  → psych (YAML); libffi → ffi gem; readline → IRB line editing
. "$(dirname "$0")/../lib/helpers.sh"
install_exit_trap

for pkg in libyaml libffi readline; do
  install_pkg_if_missing "$pkg"
done

# Configure mise to build Ruby with GCC 14 (FreeBSD binary names are gcc14/g++14)
su - "$TARGET_USER" -c 'mise settings set ruby.ruby_build_opts "CC=gcc14 CXX=g++14"'

# Trust .ruby-version files and install latest stable Ruby for the target user.
# Must run as the target user so mise writes to their config/data dirs.
# Skip the install if any Ruby version is already managed by mise.
su - "$TARGET_USER" -c '
  mise settings add idiomatic_version_file_enable_tools ruby
  if ! mise ls ruby 2>/dev/null | grep -q .; then
    mise use --global ruby@latest
  fi
'
