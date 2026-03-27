#!/bin/sh
set -eu

TARGET_USER="$1"
TARGET_HOME="$2"

for pkg in \
    noto-basic \
    noto-emoji \
    font-awesome \
    fontconfig
do
    if ! pkg info -e "$pkg" >/dev/null 2>&1; then
        pkg install -y "$pkg"
    fi
done

FONT_DIR="${TARGET_HOME}/.local/share/fonts"
mkdir -p "$FONT_DIR"

# Install selected CaskaydiaMono Nerd Font variants locally if not present
if [ ! -f "${FONT_DIR}/CaskaydiaMonoNerdFont-Regular.ttf" ]; then
    tmpdir=$(mktemp -d)
    cd "$tmpdir"

    # Use latest release redirect for up-to-date download
    fetch -o CascadiaMono.zip \
        https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaMono.zip

    mkdir CascadiaFont
    tar -xf CascadiaMono.zip -C CascadiaFont

    # Copy only the specific variants you need (add/remove as desired)
    cp CascadiaFont/CaskaydiaMonoNerdFont-Regular.ttf          "$FONT_DIR"/ 2>/dev/null || true
    cp CascadiaFont/CaskaydiaMonoNerdFont-Bold.ttf             "$FONT_DIR"/ 2>/dev/null || true
    cp CascadiaFont/CaskaydiaMonoNerdFont-Italic.ttf           "$FONT_DIR"/ 2>/dev/null || true
    cp CascadiaFont/CaskaydiaMonoNerdFont-BoldItalic.ttf       "$FONT_DIR"/ 2>/dev/null || true
    cp CascadiaFont/CaskaydiaMonoNerdFontPropo-Regular.ttf     "$FONT_DIR"/ 2>/dev/null || true
    cp CascadiaFont/CaskaydiaMonoNerdFontPropo-Bold.ttf        "$FONT_DIR"/ 2>/dev/null || true
    cp CascadiaFont/CaskaydiaMonoNerdFontPropo-Italic.ttf      "$FONT_DIR"/ 2>/dev/null || true
    cp CascadiaFont/CaskaydiaMonoNerdFontPropo-BoldItalic.ttf  "$FONT_DIR"/ 2>/dev/null || true

    rm -rf "$tmpdir"
fi

# Update font cache as the target user so fontconfig can find the fonts
su - "$TARGET_USER" -c "fc-cache -f"

printf "Fonts installed/updated in %s\n" "$FONT_DIR"
