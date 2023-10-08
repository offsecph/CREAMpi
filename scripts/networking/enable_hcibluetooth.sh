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

function check_root {
  if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2 exit 1
  fi
}

function enable_hcibluetooth {
  echo -e "Enabling hciuart service..\n"
  systemctl enable hciuart.service
  systemctl enable --now bluetooth.service
  systemctl status hciuart.service --no-pager
  systemctl status bluetooth.service --no-pager
}

function main {
  check_root
  enable_hcibluetooth
}

main
