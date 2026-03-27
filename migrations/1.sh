#!/bin/sh
# XRDP Setup Script for FreeBSD
# Sets up XRDP for remote desktop access to Window Maker
# Run with doas or as root
set -e
printf "==> Installing XRDP...\n"
pkg install -y xrdp

printf "==> Enabling XRDP in rc.conf...\n"
if ! grep -q "xrdp_enable" /etc/rc.conf; then
    printf 'xrdp_enable="YES"\n' >> /etc/rc.conf
else
    printf "==> xrdp_enable already set, skipping\n"
fi
if ! grep -q "xrdp_sesman_enable" /etc/rc.conf; then
    printf 'xrdp_sesman_enable="YES"\n' >> /etc/rc.conf
else
    printf "==> xrdp_sesman_enable already set, skipping\n"
fi

printf "==> Configuring startwm.sh for Window Maker...\n"
STARTWM=/usr/local/etc/xrdp/startwm.sh
if [ -f "$STARTWM" ] && grep -q "wmaker" "$STARTWM"; then
    printf "==> wmaker already configured in startwm.sh, skipping\n"
else
    printf '#!/bin/sh\n# Source user profile to restore login-shell PATH\n[ -f "$HOME/.profile" ] && . "$HOME/.profile"\n[ -f "$HOME/.xprofile" ] && . "$HOME/.xprofile"\nexec /usr/local/bin/wmaker\n' > "$STARTWM"
    chmod 755 "$STARTWM"
    printf "==> startwm.sh configured\n"
fi

printf "==> Starting XRDP services...\n"
service xrdp start || service xrdp restart
service xrdp-sesman start || service xrdp-sesman restart

printf "==> Opening RDP port 3389 in PF...\n"
if ! grep -q "port 3389" /etc/pf.conf; then
    sed -i '' '/block in all/i\
pass in on egress proto tcp to port 3389 keep state
' /etc/pf.conf
    pfctl -F all
    pfctl -f /etc/pf.conf
    printf "==> PF rule added for port 3389\n"
else
    printf "==> Port 3389 already in pf.conf, skipping\n"
fi

printf "\n"
printf "==> XRDP setup complete!\n"
printf "    Connect using Remote Desktop:\n"
if command -v ipconfig >/dev/null; then
    HOST_IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)
else
    HOST_IP=$(ifconfig 2>/dev/null | awk '/inet / && !/127\.0\.0\.1/ {print $2; exit}')
fi
if [ -n "$HOST_IP" ]; then
    printf "    Host: %s\n" "$HOST_IP"
else
    printf "    Host: (could not detect local IP — check with ifconfig or ip addr)\n"
fi
printf "    Port: 3389\n"
