#!/bin/bash
#
# Checks the memory split between cpu and gpu
#
function main {
 echo -e "Checking current memory split of CPU and GPU:\n"
 echo "ARM64:"
 vcgencmd get_mem arm | cut -d'=' -f2
 echo -e "\nGPU:"
 vcgencmd get_mem gpu | cut -d'=' -f2
}

main
