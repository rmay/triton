#!/bin/sh
set -eu

# 1) Find first wireless parent device (iwlwifi0, ath0, rtwn0, etc.)
WIFI_PARENT=$(sysctl -n net.wlan.devices 2>/dev/null | awk '{print $1}')

if [ -z "${WIFI_PARENT}" ]; then
    printf "No wireless devices found (net.wlan.devices is empty)\n" >&2
else
    printf "Detected Wi-Fi parent: %s\n" "${WIFI_PARENT}"

    # 2) See if any wlan(4) interface already exists
    EXISTING_WLAN=$(ifconfig -g wlan 2>/dev/null | awk '{print $1}')

    if [ -n "${EXISTING_WLAN}" ]; then
        WLAN_IF="${EXISTING_WLAN}"
    else
        # If none exist, we will create wlan0 from the parent
        WLAN_IF="wlan0"
        sysrc "wlans_${WIFI_PARENT}=${WLAN_IF}"
    fi

    printf "Using wlan interface: %s\n" "${WLAN_IF}"

    # 3) Configure the wlan interface for WPA + DHCP in rc.conf
    sysrc "ifconfig_${WLAN_IF}=WPA DHCP"

    # 4) Make sure wpa_supplicant is enabled (if you use it this way)
    sysrc wpa_supplicant_enable=YES
fi