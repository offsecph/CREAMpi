#!/bin/bash
#
# Checks the temperature of raspberry pi for 30 seconds
#

function check_root {
  if [ "$(id -u)" != "0" ]; then 
    echo "This script must be run as root" 1>&2 exit 1
  fi
}

function run_temp_loop {
  for x in `seq 1 60`
    do
      clear
      echo -e "\nChecking $HOSTNAME's temperature:\n"
      echo " --------------------------------- "
      echo "| Temp   | Count (s) | Total Time |"
      echo " --------------------------------- "
      echo -e "| `vcgencmd measure_temp | cut -d'=' -f2` |    $x     | 1 minute   |"
      echo " --------------------------------- "
      sleep 1
    done
}

function main {
    check_root
    run_temp_loop
}

main
