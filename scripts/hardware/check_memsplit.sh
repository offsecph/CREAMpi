#!/bin/bash
#
# Checks the memory split between cpu and gpu
#

function check_root {
  if [ "$(id -u)" != "0" ]; then 
    echo "This script must be run as root" 1>&2 exit 1
  fi
}

function check_memsplit {
 echo -e "Checking current memory split of CPU and GPU:\n"
 echo "ARM64:"
 vcgencmd get_mem arm | cut -d'=' -f2
 echo -e "\nGPU:"
 vcgencmd get_mem gpu | cut -d'=' -f2
}

function main {
    check_root
    check_memsplit
}

main
