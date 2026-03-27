#!/bin/sh
# Migration 2: SSH login-shell PATH
# Ensures the triton PATH is applied for SSH logins across common shells.
# Run as yourself (no doas/root needed).
set -e

TARGET_USER=$(id -un)
TARGET_HOME="$HOME"
TARGET_SHELL=$(pw usershow "$TARGET_USER" 2>/dev/null | cut -d: -f10)

if [ -z "$TARGET_HOME" ]; then
    printf "==> Could not determine home dir for %s\n" "$TARGET_USER" >&2
    exit 1
fi

printf "==> Configuring SSH login-shell PATH for %s (shell: %s)...\n" "$TARGET_USER" "$TARGET_SHELL"

TRITON_PATH='export PATH="$HOME/.local/share/triton/bin:/usr/local/GNUStep/Applications:/usr/local/GNUstep/System/Applications:$PATH"'

PROFILE="${TARGET_HOME}/.profile"
if ! grep -qF 'triton/bin' "$PROFILE" 2>/dev/null; then
    printf '%s\n' "$TRITON_PATH" >> "$PROFILE"
    printf "==> Added triton PATH to %s\n" "$PROFILE"
else
    printf "==> triton PATH already in %s, skipping\n" "$PROFILE"
fi

case "$TARGET_SHELL" in
    */bash)
        # bash reads .bash_profile first and skips .profile if it exists — bridge the gap
        BASH_PROFILE="${TARGET_HOME}/.bash_profile"
        if [ -f "$BASH_PROFILE" ] && ! grep -qF '.profile' "$BASH_PROFILE"; then
            printf '[ -f "$HOME/.profile" ] && . "$HOME/.profile"\n' >> "$BASH_PROFILE"
            printf "==> Added .profile sourcing to %s\n" "$BASH_PROFILE"
        else
            printf "==> %s already sources .profile or does not exist, skipping\n" "$BASH_PROFILE"
        fi
        ;;
    */csh|*/tcsh)
        # csh/tcsh use ~/.login for login shells — .profile is never read
        LOGIN="${TARGET_HOME}/.login"
        if ! grep -qF 'triton/bin' "$LOGIN" 2>/dev/null; then
            printf 'setenv PATH "$HOME/.local/share/triton/bin:/usr/local/GNUstep/System/Applications:$PATH"\n' >> "$LOGIN"
            printf "==> Added triton PATH to %s\n" "$LOGIN"
        else
            printf "==> triton PATH already in %s, skipping\n" "$LOGIN"
        fi
        ;;
esac

printf "==> Done\n"
