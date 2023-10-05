#!/bin/bash
#
# connect_wlan_nmcli.sh - connect droppi to a wireless network
#
#
# Set the following variables before running the script.
SSID_NAME=''
SSID_PASSPHRASE=''
WLAN_INTERFACE=wlan0
CONNECTION_TEST=1.1.1.1

function check_root {
  if [ "$(id -u)" != "0" ]; then 
    echo "This script must be run as root" 1>&2 exit 1
  fi
}

function check_wlan_interfaces {
  WLAN_INTERFACES=()
  WLAN_INTERFACES+=$(ip route list | grep -v default | awk '{print $3}' | grep w | sort -u)

  if [[ ! ${WLAN_INTERFACES[*]} =~ $WLAN_INTERFACE ]]; then
    echo "Error on the configuration file.. exiting.."
    exit
  else
    if [[ -z $SSID_NAME ]] || [[ -z $SSID_PASSPHRASE ]]; then
      echo "Error. Supply a valid SSID_NAME or SSID_PASSPHRASE"
      exit
    fi
    
    echo "Connecting to target wifi with SSID: $SSID_NAME"..
    sleep 1.5
  fi

}

function connect_wlan {
  rfkill list $(rfkill list | grep Wireless | awk -F: {'print $1'})
  rfkill unblock wifi
  nmcli radio wifi
  nmcli radio wifi on
  nmcli radio wifi
  nmcli dev wifi list; sleep 1
  nmcli dev wifi connect $SSID_NAME password "$SSID_PASSPHRASE" && sleep 1.5
  nmcli con show
  ifconfig $WLAN_INTERFACE
  ping -c 1 $CONNECTION_TEST
}

function reconnect_c2 {
  systemctl stop callhome.service && sleep 5
  systemctl start callhome.service
}

function main {
  check_root
  check_wlan_interfaces
  connect_wlan
  reconnect_c2
}

main
