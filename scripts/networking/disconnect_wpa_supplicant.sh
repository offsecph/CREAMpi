#!/bin/bash
#
# disconnect_wpa_supplicant.sh - connect CREAMpi to a wireless network (deprecated)
#
# wpa_supplicant configuration is superseded by network manager.
# it is advisable to run the connect_wlan_nmcli.sh instead.
#
# NOTE: wpa_supplicant is not persistent on reboots and service will fail.
#       you must use one network service will work at a time.
#       If you are using systemd networkmanager, kill the networkmanager daemon and
#       try again. This tool is DEPRECATED, use disconnect_wlan_nmcli.sh instead.
#
# WARNING: THIS SCRIPT MAY BREAK NETWORKMANAGER SCRIPTS and SERVICES.
#          USE connect_wlan_nmcli.sh INSTEAD!
#
# Set the following variables before running the script.

WLAN_INTERFACE=wlan0

function check_root {
  if [ "$(id -u)" != "0" ]; then 
    echo "This script must be run as root" 1>&2 exit 1
  fi
}

function disable_services {
  systemctl disable wpa_supplicant.service \
    dhclient.service
  systemctl stop wpa_supplicant.service \
    dhclient.service
}

function delete_services {
  rm -rf /etc/systemd/system/dhclient.service
  systemctl daemon-reload
}

function exec_start {
  echo "Disconnecting the wifi on $WLAN_INTERFACE.."
  sleep 1.5
}

function disconnect_wpa_supplicant {
  rfkill list $(rfkill list | grep Wireless | awk -F: {'print $1'})
  rfkill unblock wifi
  killall wpa_supplicant
  sleep 2
}

function show_interface {
  ifconfig $WLAN_INTERFACE
}

function main {
  check_root
  disable_services
  delete_services
  exec_start
  disconnect_wpa_supplicant
  show_interface
}

main
