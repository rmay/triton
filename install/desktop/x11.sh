#!/bin/sh

set -eu

# Require root (pkg, sysrc, service)
if [ "$(id -u)" -ne 0 ]; then
    printf 'This script must be run as root (use: su -)\n' >&2
    exit 1
fi

. "$(dirname "$0")/../lib/helpers.sh"
install_exit_trap

LOG_FILE="/var/log/triton-x11-install.log"
mkdir -p "$(dirname "$LOG_FILE")"
printf '=== triton x11 install started %s ===\n' "$(date '+%Y-%m-%d %H:%M:%S')" > "$LOG_FILE"

# Update system
update_system() {
    print_status "Updating system packages..."
    pkg update -f
    pkg upgrade -y
}


# Install X11 core components — prefer XLibre, fall back to XOrg
install_xwindow() {
    # Check whether XLibre is available in the current pkg repository.
    # 'pkg search -e' exits 0 only when an exact match is found.
    if pkg search xlibre >/dev/null 2>&1; then
        print_status "XLibre found in pkg repository — installing XLibre..."
        X_METAPKG="xlibre"
    else
        print_warning "XLibre not found in pkg repository — falling back to Xorg"
        X_METAPKG="xorg"
    fi

    for pkg in "$X_METAPKG" xauth xrandr xsetroot font-misc-misc; do
        if ! pkg info -e "$pkg" >/dev/null 2>&1; then
            print_status "Installing $pkg..."
            pkg install -y "$pkg"
        fi
    done

    print_success "Core X11 components installed (${X_METAPKG})"
}

# Install graphics drivers (very approximate, user should still check handbook)
install_graphics_drivers() {
    print_status "Attempting to detect GPU and install graphics drivers..."

    # FreeBSD: use pciconf instead of lspci
    gpu_info=$(pciconf -lv 2>/dev/null | grep -iE 'vga|display|3d' || true)

    if echo "$gpu_info" | grep -iq nvidia; then
        print_status "NVIDIA GPU detected, installing nvidia-driver"
        if ! pkg info -e nvidia-driver >/dev/null 2>&1; then
            pkg install -y nvidia-driver
        fi
        # Enable NVIDIA driver at boot
        sysrc kld_list+=" nvidia-modeset"
        print_warning "NVIDIA driver installed. You may need to add/adjust /boot/loader.conf and /etc/rc.conf per the FreeBSD Handbook."

    elif echo "$gpu_info" | grep -iqE 'amd|radeon|ati'; then
        print_status "AMD GPU detected, installing drm-kmod"
        if ! pkg info -e drm-kmod >/dev/null 2>&1; then
            pkg install -y drm-kmod
        fi
        print_warning "drm-kmod installed for AMD GPU. Consult the FreeBSD Handbook for the correct kld_list entries (amdgpu/radeonkms)."

    elif echo "$gpu_info" | grep -iq intel; then
        print_status "Intel GPU detected, installing drm-kmod"
        if ! pkg info -e drm-kmod >/dev/null 2>&1; then
            pkg install -y drm-kmod
        fi
        print_warning "drm-kmod installed for Intel GPU. Consult the FreeBSD Handbook for i915kms configuration."

    else
        print_warning "Could not detect a specific GPU; installing generic VESA driver"
        if ! pkg info -e xf86-video-vesa >/dev/null 2>&1; then
            pkg install -y xf86-video-vesa
        fi
    fi
}

# Install input drivers and small X tools
install_input_drivers() {
    print_status "Installing input drivers and X utilities..."

    for pkg in xf86-input-libinput xkill xprop; do
        if ! pkg info -e "$pkg" >/dev/null 2>&1; then
            print_status "Installing $pkg..."
            pkg install -y "$pkg"
        fi
    done

    print_success "Input drivers and utilities installed"
}

# Optional: Install display manager (LightDM)
install_display_manager() {
    print_status "Installing LightDM display manager..."

    if ! pkg info -e lightdm >/dev/null 2>&1; then
        pkg install -y lightdm lightdm-gtk-greeter
    fi

    # Enable dbus and lightdm at boot (required on FreeBSD)
    sysrc dbus_enable="YES"
    sysrc lightdm_enable="YES"

    # Configure the GTK greeter. The ~session indicator has an unescaped &
    # in its label string which Pango renders literally as "User &". Omitting
    # it fixes the display and is fine since Window Maker is the only session.
    GREETER_CONF="/usr/local/etc/lightdm/lightdm-gtk-greeter.conf"
    mkdir -p "$(dirname "$GREETER_CONF")"
    cat > "$GREETER_CONF" <<'EOF'
[greeter]
indicators = ~host;~spacer;~clock;~spacer;~layout;~a11y;~power
clock-format = %H:%M
font-name = CaskaydiaMono Nerd Font 11
xft-antialias = true
EOF

    print_success "LightDM installed and enabled (remember to start dbus and lightdm)"
}

main() {
    print_status "Starting X11 installation on FreeBSD..."

    update_system
    install_xwindow
    install_graphics_drivers
    install_input_drivers
    install_display_manager

    print_success "X11 installation completed!"
    print_warning "You may need to fine-tune graphics driver settings per the FreeBSD Handbook."
}

main "$@"
