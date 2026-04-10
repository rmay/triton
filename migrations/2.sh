#!/bin/sh
# Migration 2 + Nice Prompt + Auto tmux on SSH
# Configures Triton PATH, colorful prompt, and auto-tmux for SSH sessions.
# Run as yourself (no doas/root needed).

set -e

TARGET_USER=$(id -un)
TARGET_HOME="$HOME"
TARGET_SHELL=$(pw usershow "$TARGET_USER" 2>/dev/null | cut -d: -f10 || echo "")

if [ -z "$TARGET_HOME" ]; then
    printf "==> Could not determine home dir for %s\n" "$TARGET_USER" >&2
    exit 1
fi

printf "==> Configuring SSH login for %s (shell: %s)...\n" "$TARGET_USER" "$TARGET_SHELL"

# ====================== 1. Triton PATH ======================
TRITON_PATH='export PATH="$HOME/.local/share/triton/bin:/usr/local/GNUStep/Applications:/usr/local/GNUstep/System/Applications:$PATH"'
PROFILE="${TARGET_HOME}/.profile"

if ! grep -qF 'triton/bin' "$PROFILE" 2>/dev/null; then
    printf '%s\n' "$TRITON_PATH" >> "$PROFILE"
    printf "==> Added triton PATH to %s\n" "$PROFILE"
else
    printf "==> triton PATH already in %s, skipping\n" "$PROFILE"
fi

# Bash-specific: source .profile from .bash_profile
case "$TARGET_SHELL" in
    */bash)
        BASH_PROFILE="${TARGET_HOME}/.bash_profile"
        if [ -f "$BASH_PROFILE" ] && ! grep -qF '.profile' "$BASH_PROFILE" 2>/dev/null; then
            printf '[ -f "$HOME/.profile" ] && . "$HOME/.profile"\n' >> "$BASH_PROFILE"
            printf "==> Added .profile sourcing to %s\n" "$BASH_PROFILE"
        else
            printf "==> %s already sources .profile or does not exist, skipping\n" "$BASH_PROFILE"
        fi
        ;;
    */csh|*/tcsh)
        # csh/tcsh use ~/.login
        LOGIN="${TARGET_HOME}/.login"
        if ! grep -qF 'triton/bin' "$LOGIN" 2>/dev/null; then
            printf 'setenv PATH "$HOME/.local/share/triton/bin:/usr/local/GNUstep/System/Applications:$PATH"\n' >> "$LOGIN"
            printf "==> Added triton PATH to %s\n" "$LOGIN"
        else
            printf "==> triton PATH already in %s, skipping\n" "$LOGIN"
        fi
        ;;
esac

# ====================== 2. Nice Colorful Prompt + TERM fix ======================
COLOR_PROMPT='
# === Nice colorful prompt + 256-color support ===
if [ -n "$PS1" ]; then
    # Upgrade TERM for better color support (works with most terminals)
    case "$TERM" in
        xterm*|screen*|tmux*)
            export TERM="${TERM}-256color" 2>/dev/null || true
            ;;
    esac

    # Clean, modern prompt: green user@host : blue path $
    PS1="\[\e[32m\]\u@\[\e[36m\]\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ "
fi
'

if ! grep -qF 'Nice colorful prompt' "$PROFILE" 2>/dev/null; then
    printf '%s\n' "$COLOR_PROMPT" >> "$PROFILE"
    printf "==> Added colorful prompt + TERM fix to %s\n" "$PROFILE"
else
    printf "==> Colorful prompt already in %s, skipping\n" "$PROFILE"
fi

# Also add to .bash_profile for bash
if [ "$TARGET_SHELL" = */bash ] || [ -f "${TARGET_HOME}/.bash_profile" ]; then
    BASH_PROFILE="${TARGET_HOME}/.bash_profile"
    if [ -f "$BASH_PROFILE" ] && ! grep -qF 'Nice colorful prompt' "$BASH_PROFILE" 2>/dev/null; then
        printf '%s\n' "$COLOR_PROMPT" >> "$BASH_PROFILE"
        printf "==> Added colorful prompt to %s\n" "$BASH_PROFILE"
    fi
fi

# ====================== 3. Auto tmux on SSH only ======================
TMUX_AUTO='
# === Auto-start or attach tmux only for SSH sessions ===
if [ -n "$PS1" ] && [ -z "$TMUX" ] && [ -n "$SSH_TTY" ]; then
    # Shared session name (change to "$(whoami)" or "$(hostname -s)" if you want per-user/per-host)
    SESSION_NAME="main"

    # Attach if session exists, otherwise create new
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        exec tmux attach-session -t "$SESSION_NAME"
    else
        exec tmux new-session -s "$SESSION_NAME"
    fi
fi
'

if ! grep -qF 'Auto-start or attach tmux' "$PROFILE" 2>/dev/null; then
    printf '%s\n' "$TMUX_AUTO" >> "$PROFILE"
    printf "==> Added auto-tmux on SSH to %s\n" "$PROFILE"
else
    printf "==> Auto-tmux already configured in %s, skipping\n" "$PROFILE"
fi

# Also add to .bash_profile for bash
if [ "$TARGET_SHELL" = */bash ] || [ -f "${TARGET_HOME}/.bash_profile" ]; then
    BASH_PROFILE="${TARGET_HOME}/.bash_profile"
    if [ -f "$BASH_PROFILE" ] && ! grep -qF 'Auto-start or attach tmux' "$BASH_PROFILE" 2>/dev/null; then
        printf '%s\n' "$TMUX_AUTO" >> "$BASH_PROFILE"
        printf "==> Added auto-tmux to %s\n" "$BASH_PROFILE"
    fi
fi

printf "==> Configuration complete!\n"