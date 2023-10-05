#!/bin/bash
#
# enable_hostapd.sh - Enables the hostapd of the system.
#
# It may rely on how the system acts on the network to provide wireless ap service.
# Also, if the system is connected to a wireless AP, it acts as a client, therefore
# hostapd may fail on providing ssid as an access point.

function main {
  echo -e "Enabling hostapd service..\n"
  systemctl enable --now hostapd.service
  systemctl status hostapd.service --no-pager
}

main
