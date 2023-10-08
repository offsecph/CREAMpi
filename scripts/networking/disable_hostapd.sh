#!/bin/bash
#
# disable_hostapd.sh - Disables the hostapd of the system.
#
# It may rely on how the system acts on the network to provide wireless ap service.
# Also, if the system is connected to a wireless AP, it acts as a client, therefore
# hostapd may fail on providing ssid as an access point.

function check_root {
  if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2 exit 1
  fi
}

function disable_hostapd {
  echo -e "Disabling hostapd service..\n"
  systemctl disable --now hostapd.service
  systemctl status hostapd.service --no-pager
}

function main {
  check_root
  disable_hostapd
}

main
