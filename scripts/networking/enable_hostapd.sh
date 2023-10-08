#!/bin/bash
#
# enable_hostapd.sh - Enables the hostapd of the system.
#
# It may rely on how the system acts on the network to provide wireless ap service.
# Also, if the system is connected to a wireless AP, it acts as a client, therefore
# hostapd may fail on providing ssid as an access point.

function check_root {
  if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2 exit 1
  fi
}

function enable_hostapd {
  echo -e "Enabling hostapd service..\n"
  systemctl enable --now hostapd.service
  systemctl status hostapd.service --no-pager
}

function main {
  check_root
  enable_hostapd
}

main
