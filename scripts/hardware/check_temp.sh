#!/bin/bash
#
# Checks the temperature of raspberry pi for 30 seconds
#

function main {
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

main
