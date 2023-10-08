#!/bin/bash
#
# enables / disables Bluetooth hardware lock when powered on
#
# Hardware locks persist only across reboots.
#

function check_root {
  if [ "$(id -u)" != "0" ]; then 
    echo "This script must be run as root" 1>&2 exit 1
  fi
}

function enable_disable_bluetooth {
    if [[ -z `cat /boot/config.txt | grep "dtoverlay=pi4-enable-bt"` ]]; then
        echo "Bluetooth enabled.. Please reboot $HOSTNAME to apply changes"
        echo -e "\n# Uncomment to enable bluetooth\ndtoverlay=pi4-enable-bt" >> /boot/config.txt
        cat /boot/config.txt | grep 'dtoverlay=pi4-enable-bt' --color=none
    else
	    if [[ `cat /boot/config.txt | grep "dtoverlay=pi4-enable-bt"` == "dtoverlay=pi4-enable-bt" ]]; then 
                echo "Bluetooth hardwarelock on.. Please reboot $HOSTNAME to apply changes"
	        sed -i s'/dtoverlay=pi4-enable-bt/#dtoverlay=pi4-enable-bt/'g /boot/config.txt 
	        cat /boot/config.txt | grep 'dtoverlay=pi4-enable-bt' --color=none
  	    else
	        echo "Bluetooth harware lock off.. Please reboot $HOSTNAME to apply changes"
	        sed -i s'/#dtoverlay=pi4-enable-bt/dtoverlay=pi4-enable-bt/'g /boot/config.txt
	        cat /boot/config.txt | grep 'dtoverlay=pi4-enable-bt' --color=none
	   fi
    fi
}

function main {
    check_root
    enable_disable_bluetooth
}

main
