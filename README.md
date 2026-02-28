# Pi Router Configuration

A secure, automated Raspberry Pi router setup using `hostapd`, `dnsmasq`, and `nftables`.

## Prerequisites
1. Create a file in your home directory: `~/router_secrets.sh`
2. Add your credentials to that file:
   ```bash
   export WIFI_SSID="MyRouterName"
   export WIFI_PASS="MySecretPassword"
