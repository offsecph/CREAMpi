#!/bin/bash
#
# disable_hostapd.sh - Disables the hostapd of the system.
#
# It may rely on how the system acts on the network to provide wireless ap service.
# Also, if the system is connected to a wireless AP, it acts as a client, therefore
# hostapd may fail on providing ssid as an access point.

function main {
  echo -e "Disabling hostapd service..\n"
  systemctl disable --now hostapd.service
  systemctl status hostapd.service --no-pager
}

main
