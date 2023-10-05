#!/bin/bash
#
# enable_hcibluetooth.sh - Enables the hciuart controller of the system.
#
# Bluetooth service may rely on hciuart service which controls the bluetooth 
# hardware of the system. If hciuart is disabled, bluetooth may show running but
# hci hardware is turned off.
#
# Note: If hciuart service is disabled, a restart is need to remove the hardware
# lock on hciuart service. Otherwise, it will fail.

function main {
  echo -e "Enabling hciuart service..\n"
  systemctl enable hciuart.service
  systemctl enable --now bluetooth.service
  systemctl status hciuart.service --no-pager
  systemctl status bluetooth.service --no-pager
}

main
