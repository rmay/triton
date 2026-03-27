#!/bin/sh
set -eu

TARGET_USER="$1"
TARGET_HOME="$2"

NVIM_CONFIG_DIR="${TARGET_HOME}/.config/nvim"
TRITON_BASE="${TARGET_HOME}/.local/share/triton"

# Install neovim and related tools system-wide if missing
if ! command -v nvim >/dev/null 2>&1; then
    pkg install -y neovim tree-sitter-cli vim
fi

LUAROCKS_PKG=$(
  pkg rquery '%n %v' '^lua5[2-4]-luarocks$' \
    | sort -k2 -V \
    | tail -1 \
    | awk '{print $1}'
)

# Install if found and not already installed
if [ -n "$LUAROCKS_PKG" ] && ! pkg info -e "$LUAROCKS_PKG"; then
  pkg install -y "$LUAROCKS_PKG"
fi

# Only do the LazyVim setup if LazyVim is not already configured
if [ ! -f "${NVIM_CONFIG_DIR}/lua/config/lazy.lua" ]; then
    # Ensure parent directory exists
    mkdir -p "${TARGET_HOME}/.config"

    # Install LazyVim starter
    rm -rf "${NVIM_CONFIG_DIR}"
    git clone https://github.com/LazyVim/starter "${NVIM_CONFIG_DIR}"

    # Overlay a Triton nvim config if present
    if [ -d "${TRITON_BASE}/config/nvim" ]; then
        cp -R "${TRITON_BASE}/config/nvim/." "${NVIM_CONFIG_DIR}/"
    fi

    # Remove git metadata from the starter repo
    rm -rf "${NVIM_CONFIG_DIR}/.git"

    # Tweak options
    printf '%s\n' "vim.opt.relativenumber = false" >> "${NVIM_CONFIG_DIR}/lua/config/options.lua"

    # Make sure everything under ~/.config is owned by the target user
    chown -R "${TARGET_USER}:${TARGET_USER}" "${TARGET_HOME}/.config"
fi