#!/bin/sh
set -eu

TARGET_USER="$1"
TARGET_HOME="$2"

. "$(dirname "$0")/../lib/helpers.sh"
install_exit_trap

for pkg in \
  wget curl unzip \
  fd-find eza fzf ripgrep zoxide bat jq \
  xclip fastfetch btop nano py311-ranger \
  tldr plocate the_silver_searcher \
  less whois bash bash-completion \
  xterm tmux git rsync \
  libX11 libXft libXext \
  rxvt-unicode urxvt-font-size \
  password-store ncdu gum \
  imbt-firmware virtual_oss \
  neomutt
do
  install_pkg_if_missing "$pkg"
done

# Configuring sshd...

SSHD_CONF="/etc/ssh/sshd_config"

# Harden basic settings (FreeBSD sed needs -i '')
sed -i '' 's/^#Port 22/Port 22/' "$SSHD_CONF"
sed -i '' 's/^#PermitRootLogin .*/PermitRootLogin no/' "$SSHD_CONF"
sed -i '' 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' "$SSHD_CONF"

# Enable sshd at boot
sysrc sshd_enable="YES"

# Start sshd if not already running
service sshd status >/dev/null 2>&1 || service sshd start

# Set the user's shell to Bash (skip if already set)
if [ "$(getent passwd "$TARGET_USER" | cut -d: -f7)" != "/usr/local/bin/bash" ]; then
  chsh -s /usr/local/bin/bash "$TARGET_USER"
fi

cat > "$TARGET_HOME/.terminalrc" << 'EOF'
TERMINAL=xterm
EOF
chown "${TARGET_USER}:${TARGET_USER}" "$TARGET_HOME/.terminalrc"

# Enable Bluetooth driver load at boot (ng_ubt covers vast majority of hardware)
if ! grep -q '^ng_ubt_load=' /boot/loader.conf; then
    printf 'ng_ubt_load="YES"\n' >> /boot/loader.conf
fi

# Bluetooth core + helpers
for var in bluetooth_enable sdpd_enable hcsecd_enable bthidd_enable; do
    if ! grep -q "^${var}=" /etc/rc.conf; then
        sysrc ${var}="YES"
    fi
done

# CUSE for virtual_oss audio bridging
if ! grep -q 'cuse' /etc/rc.conf; then
    sysrc kld_list+=" cuse"
fi
