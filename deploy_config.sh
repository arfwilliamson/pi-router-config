#!/bin/bash

# Load the secrets
source ~/router_secrets.sh

# Use 'sed' to swap placeholders with real values and save to the real hostapd location
sed -e "s/__SSID__/$WIFI_SSID/" \
    -e "s/__PASSWORD__/$WIFI_PASS/" \
    hostapd.conf.template > /etc/hostapd/hostapd.conf

echo "Hostapd config generated successfully!"
