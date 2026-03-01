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

# 3. Deploy config files from templates
if [ -f config.sh ]; then
    echo "--- Deploying config ---"
    source config.sh
    # etc/dnsmasq.d/hotspot.conf
    echo "etc/dnsmasq/hotspot.conf"
    sed -e "s/__ROUTER_IP__/$ROUTER_IP/g" \
        -e "s/__DHCP_START__/$DHCP_RANGE_START/g" \
        -e "s/__DHCP_END__/$DHCP_RANGE_END/g" \
        template/hotspot.conf.template > etc/dnsmasq.d/hotspot.conf
    # etc/hostapd/hostapd.conf
    echo "etc/hostapd/hostapd.conf"
    sed -e "s/__SSID__/$WIFI_SSID/" \
        -e "s/__PASSWORD__/$WIFI_PASS/" \
        template/hostapd.conf.template > etc/hostapd/hostapd.conf
    # etc/systemd/network/08-wlan0.network
    echo "etc/systemd/network/08-wlan0.network"
    sed -e "s/__ROUTER_IP__/$ROUTER_IP/g" \
        template/08-wlan0.network.template > etc/systemd/network/08-wlan0.network
    # etc/nftables/nat-ap.nft
    echo "etc/nftables/nat-ap.nft"
    sed -e "s/__ROUTER_IP__/$ROUTER_IP/g" \
        -e "s/__ROUTER_NET__/$ROUTER_NET/g" \
        -e "s/__ROUTER_MASK__/$ROUTER_MASK/g" \
        template/nat-ap.nft.template > etc/nftables/nat-ap.nft
else
    echo "WARNING: config.sh not found!"
fi

# 4. Copy configuration files from etc into /etc
echo "--- Syncing configuration files to /etc ---"
cp -a etc/* /etc/

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
