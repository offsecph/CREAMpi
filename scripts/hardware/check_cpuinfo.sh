#!/bin/bash
#
# Checks the hardware info of the pi
#

function main {
  echo -e "------------------- CPUINFO -------------------"
  lscpu | grep 'Architecture' -A20 
}

main
