#!/bin/bash

# 1. Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (sudo)"
   exit 1
fi
echo "--- Starting Lab Router Restoration ---"

# 2. Install necessary packages for your stack
echo "Installing hostapd, dnsmasq, and nftables..."
apt update && apt install -y hostapd dnsmasq nftables

# 3. Copy configuration files from etc into /etc
echo "--- Syncing configuration files to /etc ---"
cp -a etc/* /etc/

# 4. Deploy hostapd.conf from template
if [ -f ~/router_secrets.sh ]; then
    echo "--- Deploying Hostapd Secret Config ---"
    source ~/router_secrets.sh
    # Note: Target the template you just copied into /etc/hostapd/
    sudo sed -i -e "s/__SSID__/$WIFI_SSID/" \
                -e "s/__PASSWORD__/$WIFI_PASS/" \
                /etc/hostapd/hostapd.conf
else
    echo "WARNING: ~/router_secrets.sh not found!"
fi

# 4. Handle Service States
echo "--- Configuring services ---"

# Unmask hostapd (Debian masks it by default on install)
systemctl unmask hostapd

# Enable all core services to start on boot
systemctl enable hostapd dnsmasq nftables systemd-networkd

# 5. NetworkManager reload
# Reload NM so it picks up the 'unmanaged-devices' rule for wlan0
systemctl restart NetworkManager

# 6. Apply Sysctl changes immediately
sysctl --system

echo "--- Restoration Complete ---"
echo "It is highly recommended to REBOOT now to initialize the wlan0 carrier."
