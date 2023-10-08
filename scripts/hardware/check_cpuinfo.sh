#!/bin/bash
#
# Checks the hardware info of the pi
#

function check_root {
  if [ "$(id -u)" != "0" ]; then 
    echo "This script must be run as root" 1>&2 exit 1
  fi
}

function check_cpuinfo {
  echo -e "------------------- CPUINFO -------------------"
  lscpu | grep 'Architecture' -A20 
}

function main {
    check_root
    check_cpuinfo
}

main
