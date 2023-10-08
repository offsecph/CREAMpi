#!/bin/bash
#
# Checks the current storage of rasberry pi
#

function check_root {
  if [ "$(id -u)" != "0" ]; then 
    echo "This script must be run as root" 1>&2 exit 1
  fi
}

function check_storage {
  df -h
  echo
  df -h | grep /root -B1
  echo
  duf
}

function main {
    check_root
    check_storage
}

main
