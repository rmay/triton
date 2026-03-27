#!/bin/sh
set -eu

ansi_art='
████████╗██████╗ ██╗████████╗ ██████╗ ███╗   ██╗
╚══██╔══╝██╔══██╗██║╚══██╔══╝██╔═══██╗████╗  ██║
   ██║   ██████╔╝██║   ██║   ██║   ██║██╔██╗ ██║
   ██║   ██╔══██╗██║   ██║   ██║   ██║██║╚██╗██║
   ██║   ██║  ██║██║   ██║   ╚██████╔╝██║ ╚████║
   ╚═╝   ╚═╝  ╚═╝╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═══╝
'

show_logo() {
  clear
  printf '\n%s\n\n' "$ansi_art"
}

show_subtext() {
  printf '%s\n\n' "$1"
}

check_kernel_reboot_needed() {
  running=$(uname -r)
  if command -v freebsd-version >/dev/null 2>&1; then
    installed=$(freebsd-version -k)
  else
    installed=$running
  fi

  if [ "$running" != "$installed" ]; then
    show_logo
    show_subtext "Kernel updated! After reboot, restart the installation script. Rebooting now..."
    sleep 2
    shutdown -r now
  else
    printf 'Kernel up to date (%s)\n' "$running"
  fi
}

# From here on, we are root
show_logo

# Bootstrap pkg if needed
if ! command -v pkg >/dev/null 2>&1; then
  printf "Bootstrapping pkg...\n"
  ASSUME_ALWAYS_YES=yes pkg bootstrap
fi

if [ "$(uname -m)" = "amd64" ]; then
  REPO_CONF="/usr/local/etc/pkg/repos/FreeBSD.conf"
  mkdir -p /usr/local/etc/pkg/repos

  if [ ! -f "$REPO_CONF" ]; then
    cat > "$REPO_CONF" <<'EOF'
FreeBSD: {
  url: "pkg+http://pkg.FreeBSD.org/${ABI}/latest",
  mirror_type: "srv",
  signature_type: "fingerprints",
  fingerprints: "/usr/share/keys/pkg",
  enabled: yes
}
EOF
  else
    sed -i '' 's|/quarterly"|/latest"|g' "$REPO_CONF"
  fi
fi

PKG_CONF="/usr/local/etc/pkg.conf"
touch "$PKG_CONF"

if ! grep -q "ASSUME_ALWAYS_YES" "$PKG_CONF" 2>/dev/null; then
  printf '%s\n' 'ASSUME_ALWAYS_YES = yes;' >> "$PKG_CONF"
fi

PROFILE_FILE="/etc/profile"
if ! grep -q "CLICOLOR=1 pkg" "$PROFILE_FILE" 2>/dev/null; then
  cat >> "$PROFILE_FILE" <<'EOF'

# Colorful pkg wrapper
alias pkg='env CLICOLOR=1 pkg'
EOF
fi

printf "Updating and upgrading pkg...\n"
pkg update -f
pkg upgrade -y

check_kernel_reboot_needed
