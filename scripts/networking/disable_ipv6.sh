#!/bin/bash
#
# disable_ipv6.sh - Disables ipv6 on all interface
#
# ipv6 is enabled by default in an interface. This script disables it.
#
INTERFACE=wlan0

function check_interfaces {
  INTERFACES=()
  INTERFACES+=$(ip route list | grep -v default | awk '{print $3}' | sort -u)

  if [[ ! ${INTERFACES[*]} =~ $INTERFACE ]]; then
    echo "Error on the configuration file.. exiting.."
    exit
  else
    echo -e "Disabling ipv6 on all interfaces..\n"
    sleep 1
  fi

}

function disable_ipv6 {
  sysctl -w net.ipv6.conf.all.disable_ipv6=1
  sysctl -w net.ipv6.conf.default.disable_ipv6=1
  sysctl -w net.ipv6.conf.$INTERFACE.disable_ipv6=1
  sysctl -p
  echo "" && sleep 1.5
  ifconfig | awk 'BEGIN{ORS=RS="\n\n"} !/^lo/{print}'
}

function main {
  check_interfaces
  disable_ipv6
}

main
