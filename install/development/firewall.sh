#!/bin/sh
set -eu

# Enable pf at boot
if [ "$(sysrc -n pf_enable 2>/dev/null || echo NO)" != "YES" ]; then
    sysrc pf_enable="YES"
fi

# Write pf.conf
TMP=$(mktemp)

cat > "$TMP" <<'EOF'
set skip on lo

block in all
pass out all keep state

pass in on egress proto tcp to port 22 keep state
EOF

if [ ! -f /etc/pf.conf ] || ! cmp -s "$TMP" /etc/pf.conf; then
    cp "$TMP" /etc/pf.conf
fi

rm -f "$TMP"

# Load and enable rules
# Start pf only if not already running
if ! service pf onestatus >/dev/null 2>&1; then
    service pf start
fi

# Reload rules only if pf.conf exists
if [ -f /etc/pf.conf ]; then
    pfctl -f /etc/pf.conf
fi

# Enable pf only if not already enabled
if ! pfctl -s info 2>/dev/null | grep -q 'Status: Enabled'; then
    pfctl -e
fi
