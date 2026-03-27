#!/bin/sh
set -eu

TARGET_USER="$1"
TARGET_HOME="$2"

printf 'TARGET_USER=%s TARGET_HOME=%s\n' "$1" "$2"

# Setup theme links
mkdir -p "$TARGET_HOME/.config/triton/themes"

THEME_SRC="$TARGET_HOME/.local/share/triton/themes"
if [ -d "$THEME_SRC" ]; then
  for f in "$THEME_SRC"/*; do
    [ -e "$f" ] || continue
    ln -nfs "$f" "$TARGET_HOME/.config/triton/themes/"
  done
fi

# Set initial theme basics
mkdir -p "$TARGET_HOME/.config/triton/current"

ln -nfs \
  "$TARGET_HOME/.config/triton/themes/tokyo-night" \
  "$TARGET_HOME/.config/triton/current/theme"

ln -nfs \
  "$TARGET_HOME/.config/triton/current/theme/backgrounds/1-background.jpg" \
  "$TARGET_HOME/.config/triton/current/background"

# Set specific app links for current theme
mkdir -p "$TARGET_HOME/.config/nvim/lua/plugins"
ln -nfs \
  "$TARGET_HOME/.config/triton/current/theme/neovim.lua" \
  "$TARGET_HOME/.config/nvim/lua/plugins/theme.lua"

mkdir -p "$TARGET_HOME/.config/btop/themes"
ln -nfs \
  "$TARGET_HOME/.config/triton/current/theme/btop.theme" \
  "$TARGET_HOME/.config/btop/themes/current.theme"