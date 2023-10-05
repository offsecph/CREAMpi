#!/bin/bash
#
# Checks the temperature of raspberry pi for 30 seconds
#

function main {
  echo "Checking $HOSTNAME's temperature:"
  for x in `seq 1 10`
    do
      vcgencmd measure_temp | cut -d'=' -f2
      sleep 1
    done
}

main
