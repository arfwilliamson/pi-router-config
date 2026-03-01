# Pi Router Configuration

A secure, automated Raspberry Pi router setup using `hostapd`, `dnsmasq`, and `nftables`.

This should be easy with "nmcli dev wifi hotspot ifname wlp3s0" but that fails with
"Error: Connection activation failed: 802.1X supplicant took too long to authenticate."

This approach makes wlan0 unmanaged and uses simple configurations for the relevant
daemons to setup a 2.5GHz wifi hotspot on wlan0 that connects to the main router on 
wlan1 using a 5GHz wifi dongle.

## Prerequisites
1. Raspbian Trixie Lite 32 bit version
2. Create a file in your home directory: `config.sh`
3. Add credentials and sensitive information to that file:
   ```bash
   export WIFI_SSID="WiFiName"
   export WIFI_PASS="WiFiPassword"
   # Fixed IP address for the router outside of the DHCP range below
   export ROUTER_IP="RouterIPAddress"
   # Since it will be used in a sed expression, escape the forward slash with two back slashes
   export ROUTER_NET="RouterNetwork\\/24"
   export ROUTER_MASK="RouterNetmask"
   export DHCP_RANGE_START="StartIPAddress"
   export DHCP_RANGE_END="EndIPAddress"
