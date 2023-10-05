#!/bin/bash
#
# enable_dhcpd.sh - Enables the dhcp server of the system.
#
# It may rely on hostapd service, to provide ip address on connecting hosts.
# Also, if the system is connected to a wireless AP, it acts as a client, therefore
# isc-dhcp-server.service may fail to run.

function main {
  echo -e "Enabling isc-dhcp-server service..\n"
  systemctl enable --now isc-dhcp-server.service
  systemctl status isc-dhcp-server.service --no-pager
}

main
