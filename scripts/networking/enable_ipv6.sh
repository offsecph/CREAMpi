#!/bin/bash
#
# enable_ipv6.sh - Enables ipv6 on all interface
#
# ipv6 is enabled by default in an interface. If it is disabled,
# this script can reenable it.
#
INTERFACE=wlan0

function check_root {
  if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2 exit 1
  fi
}

function check_interfaces {
  INTERFACES=()
  INTERFACES+=$(ip route list | grep -v default | awk '{print $3}' | sort -u)

  if [[ ! ${INTERFACES[*]} =~ $INTERFACE ]]; then
    echo "Error on the configuration file.. exiting.."
    exit
  else
    echo -e "Enabling ipv6 on all interfaces..\n"
    sleep 1
  fi
}

function enable_ipv6 {
  sysctl -w net.ipv6.conf.all.disable_ipv6=0
  sysctl -w net.ipv6.conf.default.disable_ipv6=0
  sysctl -w net.ipv6.conf.$INTERFACE.disable_ipv6=0
  sysctl -p
  echo "" && sleep 1.5
  ifconfig | awk 'BEGIN{ORS=RS="\n\n"} !/^lo/{print}'
}

function main {
  check_root
  check_interfaces
  enable_ipv6
}

main
