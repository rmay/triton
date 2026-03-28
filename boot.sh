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

printf "\n$ansi_art\n"

printf "\nRun this script as root (use: su)\n"

# Ensure we're on FreeBSD
if [ "$(uname -s)" != "FreeBSD" ]; then
  printf "This script is intended for FreeBSD.\n"
  exit 1
fi

# Ask which user to install for
printf 'Enter the login name of the user to install Triton for: '
IFS= read -r TARGET_USER

if [ -z "$TARGET_USER" ]; then
    printf 'No username entered, aborting.\n' >&2
    exit 1
fi

# Verify user exists
if ! id "$TARGET_USER" >/dev/null 2>&1; then
    printf ‘User "%s" does not exist.\n’ "$TARGET_USER" >&2
    exit 1
fi

# Get the user’s home directory from pw(8)
printf 'Checking for user folder.\n'
TARGET_HOME=$(awk -F: -v user="$TARGET_USER" '$1==user{print $6}' /etc/passwd)

if [ -z "$TARGET_HOME" ]; then
    printf ‘Could not determine home directory for user "%s".\n’ "$TARGET_USER" >&2
    exit 1
fi

TRITON_DIR="$TARGET_HOME/.local/share/triton"

# Set GECOS (display name) so LightDM shows the login name instead of "User &"
pw usermod "$TARGET_USER" -c "$TARGET_USER"

env ASSUME_ALWAYS_YES=yes pkg bootstrap >/dev/null 2>&1 || true
env ASSUME_ALWAYS_YES=yes pkg update -f

if ! pkg info -e git; then
    printf '\nInstalling git\n'
    pkg install -y git
else
    printf '\nGit already installed, skipping\n'
fi

if [ ! -d /usr/ports/.git ]; then
    printf '\nInstalling ports\n'
    git clone --depth 1 https://git.FreeBSD.org/ports.git /usr/ports
else
    printf '\nPorts tree already exists, skipping\n'
fi

if ! pkg info -e doas; then
    printf '\nInstalling doas\n'
    pkg install -y doas
cat > /usr/local/etc/doas.conf <<'EOF'
permit persist :wheel
EOF
    pw usermod "$TARGET_USER" -G wheel
else
    printf '\doas already installed, skipping\n'
fi


printf '\nCloning Triton into %s\n' "$TRITON_DIR"

# Ensure parent directory exists
mkdir -p "$TARGET_HOME/.local/share"

# Remove any old checkout and clone as root, then fix ownership
rm -rf "$TRITON_DIR"
git clone https://github.com/rmay/triton/triton.git "$TRITON_DIR" >/dev/null

# Use custom branch if instructed
if [ -n "${TRITON_REF:-}" ]; then
    printf 'Using branch: %s\n' "$TRITON_REF"
    cd "$TRITON_DIR" || exit 1
    git fetch origin "$TRITON_REF" >/dev/null 2>&1 && git checkout "$TRITON_REF" >/dev/null 2>&1
    cd - >/dev/null 2>&1 || true
fi

# Ensure the Triton tree is owned by the target user
chown -R "$TARGET_USER":"$TARGET_USER" "$TARGET_HOME/.local"

printf '\n\nTESTING\n\n'

printf '\nInstallation starting as user %s...\n' "$TARGET_USER"
sh "$TRITON_DIR/install.sh" "$TARGET_USER" "$TARGET_HOME"