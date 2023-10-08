#!/bin/bash
#
# disable_dhcpd.sh - Disables the dhcp server of the system.
#
# It may rely on hostapd service, to provide ip address on connecting hosts.
# Also, if the system is connected to a wireless AP, it acts as a client, therefore
# isc-dhcp-server.service may fail to run.

function check_root {
  if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2 exit 1
  fi
}

function disable_dhcpd {
  echo -e "Disabling isc-dhcp-server service..\n"
  systemctl disable --now isc-dhcp-server.service
  systemctl status isc-dhcp-server.service --no-pager
}

function main {
  check_root
  disable_dhcpd
}

main
