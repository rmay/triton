#!/bin/sh
# Full SSH login setup: Triton PATH + Nice colorful prompt + Auto tmux + Colored ls
# Fixed TERM handling and added colored ls for FreeBSD

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

# Bash bridge
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
        LOGIN="${TARGET_HOME}/.login"
        if ! grep -qF 'triton/bin' "$LOGIN" 2>/dev/null; then
            printf 'setenv PATH "$HOME/.local/share/triton/bin:/usr/local/GNUstep/System/Applications:$PATH"\n' >> "$LOGIN"
            printf "==> Added triton PATH to %s\n" "$LOGIN"
        else
            printf "==> triton PATH already in %s, skipping\n" "$LOGIN"
        fi
        ;;
esac

# ====================== 2. Smart Colorful Prompt + TERM fix ======================
COLOR_PROMPT='
# === Smart colorful prompt + safe TERM upgrade ===
if [ -n "$PS1" ]; then
    # Safe TERM upgrade — only add -256color if missing
    case "$TERM" in
        *-256color|*-256colours)
            ;;
        xterm*|screen*|tmux*|rxvt*)
            export TERM="${TERM}-256color"
            ;;
    esac

    # Nice clean prompt
    PS1="\[\e[32m\]\u@\[\e[36m\]\h\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ "
fi
'

if ! grep -qF 'Smart colorful prompt' "$PROFILE" 2>/dev/null; then
    printf '%s\n' "$COLOR_PROMPT" >> "$PROFILE"
    printf "==> Added smart colorful prompt + TERM fix to %s\n" "$PROFILE"
else
    printf "==> Colorful prompt already in %s, skipping\n" "$PROFILE"
fi

# Add to .bash_profile too (for bash)
if [ "$TARGET_SHELL" = */bash ] || [ -f "${TARGET_HOME}/.bash_profile" ]; then
    BASH_PROFILE="${TARGET_HOME}/.bash_profile"
    if [ -f "$BASH_PROFILE" ] && ! grep -qF 'Smart colorful prompt' "$BASH_PROFILE" 2>/dev/null; then
        printf '%s\n' "$COLOR_PROMPT" >> "$BASH_PROFILE"
        printf "==> Added smart colorful prompt to %s\n" "$BASH_PROFILE"
    fi
fi

# ====================== 3. Colored ls (FreeBSD style) + useful aliases ======================
LS_COLORS='
# === Colored ls for FreeBSD + handy aliases ===
if [ -n "$PS1" ]; then
    export CLICOLOR=1
    # Nice readable color scheme (directories bright blue, executables green, etc.)
    export LSCOLORS="ExGxFxdxCxDxDxhbadExEx"

    # Aliases (work in both bash and sh)
    alias ls="ls -G"          # -G enables colors on FreeBSD
    alias ll="ls -lG"         # long listing with colors
    alias la="ls -laG"        # show hidden files too
fi
'

if ! grep -qF 'Colored ls for FreeBSD' "$PROFILE" 2>/dev/null; then
    printf '%s\n' "$LS_COLORS" >> "$PROFILE"
    printf "==> Added colored ls + aliases to %s\n" "$PROFILE"
else
    printf "==> Colored ls already configured in %s, skipping\n" "$PROFILE"
fi

# Also add to .bash_profile for bash
if [ "$TARGET_SHELL" = */bash ] || [ -f "${TARGET_HOME}/.bash_profile" ]; then
    BASH_PROFILE="${TARGET_HOME}/.bash_profile"
    if [ -f "$BASH_PROFILE" ] && ! grep -qF 'Colored ls for FreeBSD' "$BASH_PROFILE" 2>/dev/null; then
        printf '%s\n' "$LS_COLORS" >> "$BASH_PROFILE"
        printf "==> Added colored ls to %s\n" "$BASH_PROFILE"
    fi
fi

# ====================== 4. Auto tmux on SSH only ======================
TMUX_AUTO='
# === Auto tmux only for SSH sessions ===
if [ -n "$PS1" ] && [ -z "$TMUX" ] && [ -n "$SSH_TTY" ]; then
    SESSION_NAME="main"

    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        exec tmux attach-session -t "$SESSION_NAME"
    else
        exec tmux new-session -s "$SESSION_NAME"
    fi
fi
'

if ! grep -qF 'Auto tmux only for SSH' "$PROFILE" 2>/dev/null; then
    printf '%s\n' "$TMUX_AUTO" >> "$PROFILE"
    printf "==> Added auto-tmux on SSH to %s\n" "$PROFILE"
else
    printf "==> Auto-tmux already configured in %s, skipping\n" "$PROFILE"
fi

# Add to .bash_profile too
if [ "$TARGET_SHELL" = */bash ] || [ -f "${TARGET_HOME}/.bash_profile" ]; then
    BASH_PROFILE="${TARGET_HOME}/.bash_profile"
    if [ -f "$BASH_PROFILE" ] && ! grep -qF 'Auto tmux only for SSH' "$BASH_PROFILE" 2>/dev/null; then
        printf '%s\n' "$TMUX_AUTO" >> "$BASH_PROFILE"
        printf "==> Added auto-tmux to %s\n" "$BASH_PROFILE"
    fi
fi

printf "==> Configuration complete!\n"