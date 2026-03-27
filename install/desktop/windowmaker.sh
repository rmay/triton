#!/bin/sh
set -eu

TARGET_USER="$1"
TARGET_HOME="$2"

. "$(dirname "$0")/../lib/helpers.sh"
install_exit_trap

print_status "Starting Window Maker installation for user ${TARGET_USER}..."

# Core Window Maker package (includes extra themes on FreeBSD)
print_status "Installing core Window Maker package..."

for package in \
  windowmaker \
  gnustep-base \
  gnustep-gui \
  gnumail \
  gworkspace \
  imageviewer
do
  install_pkg_if_missing "$package"
done

# Optional but recommended packages (FreeBSD names)
print_status "Installing optional dockapps and helpers..."

# Dockapps / utilities
for package in \
  wmclock \
  wmcpuload \
  wmmemfree \
  wmmemload \
  wmnetload \
  wmsystemtray
do
  install_pkg_if_missing "$package"
done

# Audio
for package in \
  pulseaudio \
  pasystray
do
  install_pkg_if_missing "$package"
done

# Fonts and launchers, editor, misc X tools
for package in \
  dejavu \
  dmenu \
  rofi \
  xman \
  xpdf \
  xclock \
  xlockmore \
  xscreensaver
do
  install_pkg_if_missing "$package"
done

print_status "Installing apps..."

for pkg in \
  vlc libreoffice gimp musicpd ncmpcpp \
  nsxiv mpv evince-lite imv \
  xcalc thunar \
  waterfox \
  dunst libnotify flameshot \
  xdg-utils \
  desktop-file-utils \
  leafpad pinta \
  networkmgr feh
do
  install_pkg_if_missing "$pkg"
done

# These packages are frequently absent from the pkg repo due to build constraints.
for pkg in chromium logseq falkon nextcloudclient; do
  install_pkg_if_missing "$pkg"
done

printf 'Checking for directory\n'
if [ ! -d "${TARGET_HOME}/GNUstep/Library/WindowMaker" ]; then
    mkdir -p "$TARGET_HOME/GNUstep/Library/WindowMaker"
    chown -R "${TARGET_USER}:${TARGET_USER}" "${TARGET_HOME}/GNUstep/Library/WindowMaker"
fi

printf 'Creating autostart\n'
if [ ! -f "$TARGET_HOME/GNUstep/Library/WindowMaker/autostart" ]; then
cat > "$TARGET_HOME/GNUstep/Library/WindowMaker/autostart" <<'EOF'
#!/bin/sh
# Only start these if they haven't been already started
#!/bin/sh
 
# Check if a process is already running on the current X display
is_running_on_display() {
    local name="$1"
    for pid in $(pgrep -u "$(id -u)" "$name" 2>/dev/null); do
        if procstat -e "$pid" 2>/dev/null | grep -q "DISPLAY=$DISPLAY"; then
            return 0
        fi
    done
    return 1
}
 
# Notifications
if ! is_running_on_display dunst; then
    dunst &
fi
# Keybindings
if ! is_running_on_display xbindkeys; then
    xbindkeys &
fi
# System tray
if ! is_running_on_display pasystray; then
    pasystray &
fi
# Screensaver
if ! is_running_on_display xscreensaver; then
    xscreensaver -nosplash &
fi
# Network manager
if ! is_running_on_display networkmgr; then
    networkmgr &
fi
wmsetbg ~/.config/triton/current/background &
EOF
chown "${TARGET_USER}:${TARGET_USER}" "${TARGET_HOME}/GNUstep/Library/WindowMaker/autostart"
chmod +x "$TARGET_HOME/GNUstep/Library/WindowMaker/autostart"
fi
printf 'Finished creating autostart\n'

configure_xscreensaver() {
  printf 'Start configuration of xscreensaver\n'
  set -eu

  CONFIG="$TARGET_HOME/.xscreensaver"

  set_kv() {
    key="$1"
    value="$2"
    if grep -q -E "^${key}:" "$CONFIG" 2>/dev/null; then
      sed -i '' -E "s|^(${key}:[[:space:]]*).*|\1${value}|" "$CONFIG"
    else
      printf "%s: %s\n" "$key" "$value" >>"$CONFIG"
    fi
  }

  if [ ! -f "$CONFIG" ]; then
    xscreensaver-command -initialize >/dev/null 2>&1 || true
  fi

  pkill xscreensaver 2>/dev/null || true

  set_kv "timeout"     "0:10:00"
  set_kv "lockTimeout" "0:15:00"
  set_kv "cycle"       "0:10:00"
  set_kv "mode"        "random"
  set_kv "dpmsEnabled" "False"

  printf "Setting\n"
  printf '%s\n' "$CONFIG"
  chown "${TARGET_USER}:${TARGET_USER}" "$CONFIG"
  printf "\nDone\n"

  nohup xscreensaver -nosplash >/dev/null 2>&1 &
}

configure_xscreensaver

print_status "Setting up Window Maker configuration..."

# Ensure GNUstep directory exists
if [ ! -d "${TARGET_HOME}/GNUstep" ]; then
  mkdir -p "${TARGET_HOME}/GNUstep"
  chown -R "${TARGET_USER}:${TARGET_USER}" "${TARGET_HOME}/GNUstep"
  print_success "Created GNUstep directory at ${TARGET_HOME}/GNUstep"
fi

# Ensure Pictures directory exists for screenshots
if [ ! -d "${TARGET_HOME}/Pictures" ]; then
  mkdir -p "${TARGET_HOME}/Pictures"
  chown -R "${TARGET_USER}:${TARGET_USER}" "${TARGET_HOME}/Pictures"
  print_success "Created Pictures directory at ${TARGET_HOME}/Pictures"
fi

# Create .Xresources for the user
XR="${TARGET_HOME}/.Xresources"
cat >"$XR" <<'EOF'
! General settings
URxvt.depth:              256
URxvt.geometry:           90x30
URxvt.transparent:        false
URxvt.loginShell:         false
URxvt.visualBell:         true
URxvt.termName:           rxvt-unicode-256color

! Fonts (wildcard * for all instances)
URxvt*font:               xft:CaskaydiaMono NF:size=12
URxvt*boldFont:           xft:CaskaydiaMono NF:size=12
URxvt.letterSpace:        0

! Scrollbar
URxvt.scrollStyle:        rxvt
URxvt.scrollBar:          true

! Perl extensions (tabbed)
URxvt.perl-ext-common:    default,tabbed,clipboard   ! Add 'default' for safety
URxvt.tabbed.tabbar-fg:   2
URxvt.tabbed.tabbar-bg:   0
URxvt.tabbed.tab-fg:      3
URxvt.tabbed.tab-bg:      0

URxvt.keysym.Control-Shift-C: eval:selection_to_clipboard
URxvt.keysym.Control-Shift-V: eval:paste_clipboard


xcalc*background: #282828
xcalc*foreground: #ffffff
xcalc*button.background: #3a3a3a
xcalc*button.foreground: #ffcc00
xcalc*display.background: #1e1e1e
xcalc*display.foreground: #00ff00
xcalc*font: 10x20

*.faceName: CaskaydiaMono Nerd Font Mono
*.faceSize: 12
*.background: #1e1e2e
*.foreground: #cdd6f4
*.cursorColor: #f5c2e7
*.color0: #1d2021
*.color1: #cc241d
*.color2: #98971a
*.color3: #d79921
*.color4: #458588
*.color5: #b16286
*.color6: #689d6a
*.color7: #a89984
*.color8: #928374
*.color9: #fb4934
*.color10: #b8bb26
*.color11: #fabd2f
*.color12: #83a598
*.color13: #d3869b
*.color14: #8ec07c
*.color15: #ebdbb2

XTerm*selectToClipboard: true
XTerm*VT100.translations: #override \
    Ctrl Shift <Key>C: copy-selection(CLIPBOARD) \n\
    Ctrl Shift <Key>V: insert-selection(CLIPBOARD)


EOF

chown "${TARGET_USER}:${TARGET_USER}" "$XR"
print_success "Wrote ${XR}"

# Create .xprofile entry for Window Maker
XPROFILE="${TARGET_HOME}/.xprofile"
if [ ! -f "$XPROFILE" ]; then
  cat >"$XPROFILE" <<'EOF'
#!/bin/sh

export PATH="$HOME/.local/share/triton/bin:/usr/local/GNUStep/Applications:/usr/local/GNUstep/System/Applications:/usr/local/GNUstep/System/Applications/ImageViewer.app/:$PATH"

xset -dpms
xset s off
xset s noblank

xset +fp /usr/local/share/fonts/misc
xset fp rehash

# Load .Xresources
[ -f "$HOME/.Xresources" ] && xrdb -merge "$HOME/.Xresources"

. /usr/local/GNUstep/System/Library/Makefiles/GNUstep.sh

EOF
  chmod +x "$XPROFILE"
  chown "${TARGET_USER}:${TARGET_USER}" "$XPROFILE"
  print_success "Created .xprofile with Window Maker as the session"
fi

# Ensure PATH is available in SSH login shells for all common shells
TRITON_PATH='export PATH="$HOME/.local/share/triton/bin:/usr/local/GNUStep/Applications:/usr/local/GNUstep/System/Applications:$PATH"'
TARGET_SHELL=$(pw usershow "$TARGET_USER" 2>/dev/null | cut -d: -f10)

PROFILE="${TARGET_HOME}/.profile"
if ! grep -qF 'triton/bin' "$PROFILE" 2>/dev/null; then
  printf '%s\n' "$TRITON_PATH" >> "$PROFILE"
  chown "${TARGET_USER}:${TARGET_USER}" "$PROFILE"
fi

case "$TARGET_SHELL" in
  */bash)
    # bash reads .bash_profile first and skips .profile if it exists — bridge the gap
    BASH_PROFILE="${TARGET_HOME}/.bash_profile"
    if [ -f "$BASH_PROFILE" ] && ! grep -qF '.profile' "$BASH_PROFILE"; then
      printf '[ -f "$HOME/.profile" ] && . "$HOME/.profile"\n' >> "$BASH_PROFILE"
      chown "${TARGET_USER}:${TARGET_USER}" "$BASH_PROFILE"
    fi
    ;;
  */csh|*/tcsh)
    # csh/tcsh use ~/.login for login shells — .profile is never read
    LOGIN="${TARGET_HOME}/.login"
    if ! grep -qF 'triton/bin' "$LOGIN" 2>/dev/null; then
      printf 'setenv PATH "$HOME/.local/share/triton/bin:/usr/local/GNUstep/System/Applications:$PATH"\n' >> "$LOGIN"
      chown "${TARGET_USER}:${TARGET_USER}" "$LOGIN"
    fi
    ;;
esac

print_success "Window Maker setup completed for ${TARGET_USER}"
