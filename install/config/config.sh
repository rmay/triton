#!/bin/sh
set -eu

TARGET_USER="$1"
TARGET_HOME="$2"

TRITON_BASE="${TARGET_HOME}/.local/share/triton"

if [ -d "${TRITON_BASE}/config" ]; then
    mkdir -p "${TARGET_HOME}/.config"
    # Remove any destination symlinks that conflict with source files so cp
    # does not follow them and hit permission errors on re-runs.
    # Use a temp file to avoid a subshell (pipe) swallowing errors under set -eu.
    _cfg_tmp=$(mktemp /tmp/triton_cfg.XXXXXX)
    find "${TRITON_BASE}/config" -type f > "$_cfg_tmp"
    while IFS= read -r src; do
        rel="${src#${TRITON_BASE}/config/}"
        dst="${TARGET_HOME}/.config/${rel}"
        [ -L "$dst" ] && rm -f "$dst"
    done < "$_cfg_tmp"
    rm -f "$_cfg_tmp"
    cp -R "${TRITON_BASE}/config/." "${TARGET_HOME}/.config/"
fi
chown -R "$TARGET_USER":"$TARGET_USER" "$TARGET_HOME/.config"

# This just writes a .bashrc; it does not require bash to be the login shell.
printf '%s\n' "source ${TRITON_BASE}/default/bash/rc" > "${TARGET_HOME}/.bashrc"
chown "$TARGET_USER":"$TARGET_USER" "$TARGET_HOME/.bashrc"

mkdir -p "${TARGET_HOME}/.local/share/applications"
cp "${TRITON_BASE}/applications/"*.desktop "${TARGET_HOME}/.local/share/applications/" 2>/dev/null || true
update-desktop-database "${TARGET_HOME}/.local/share/applications" 2>/dev/null || true
chown -R "$TARGET_USER":"$TARGET_USER" "$TARGET_HOME/.local/share/applications"

pw groupmod operator -m $TARGET_USER

GNUPG_ETC="/usr/local/etc/gnupg"

mkdir -p "${GNUPG_ETC}"
if [ -f "${TRITON_BASE}/default/gpg/dirmngr.conf" ]; then
    cp "${TRITON_BASE}/default/gpg/dirmngr.conf" "${GNUPG_ETC}/dirmngr.conf"
    chmod 644 "${GNUPG_ETC}/dirmngr.conf"
fi

# Restart dirmngr if available
if command -v gpgconf >/dev/null 2>&1; then
    gpgconf --kill dirmngr || true
    gpgconf --launch dirmngr || true
fi

su - "$TARGET_USER" -c '
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global pull.rebase true
git config --global init.defaultBranch master
'

HIGHLIGHT='\033[31m'
RESET='\033[0m'

printf '%bGit user name%b> ' "$HIGHLIGHT" "$RESET"
IFS= read -r GIT_USER_NAME

printf '%bGit email%b> ' "$HIGHLIGHT" "$RESET"
IFS= read -r GIT_USER_EMAIL

safe_name=$(printf "%s" "$GIT_USER_NAME" | sed "s/'/'\\\\''/g")
safe_email=$(printf "%s" "$GIT_USER_EMAIL" | sed "s/'/'\\\\''/g")

su - "$TARGET_USER" -c "git config --global user.name '$safe_name'"
su - "$TARGET_USER" -c "git config --global user.email '$safe_email'"
