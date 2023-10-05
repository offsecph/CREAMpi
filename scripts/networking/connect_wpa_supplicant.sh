#!/bin/bash
#
# wpa_supplicant.sh - connect droppi to a wireless network (deprecated)
# Note: wpa_supplicant is not persistent on reboots. 
# you must create a service to make it persist on boot.
#
# wpa_supplicant configuration is superseded by network manager.
# it is advisable to run the wlan_nmcli.sh instead.
#
# Set the following variables before running the script.
SSID_NAME=""
SSID_PASSPHRASE=""
WLAN_INTERFACE=wlan0

function check_root {
  if [ "$(id -u)" != "0" ]; then 
    echo "This script must be run as root" 1>&2 exit 1
  fi
}

function exec_start {
  echo "Connecting to target wifi with SSID: $SSID_NAME"..
}

function main {
  exec_start; sleep 1.5
  rfkill list $(rfkill list | grep Wireless | awk -F: {'print $1'})
  rfkill unblock wifi
  wpa_passphrase "$SSID_NAME" "$SSID_PASSPHRASE" | tee /etc/wpa_supplicant/wpa_supplicant.conf
  sed -ie '/#psk/d' /etc/wpa_supplicant/wpa_supplicant.conf
  wpa_supplicant -c /etc/wpa_supplicant/wpa_supplicant.conf -i $WLAN_INTERFACE
  dhclient -4 $WLAN_INTERFACE
  ifconfig $WLAN_INTERFACE
  ping -c 1 google.com
  sleep 1 
  systemctl stop callhome
}

check_root
main
