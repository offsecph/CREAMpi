#!/bin/bash
#
# enables / disables LED when powered on
#
#

function check_root {
  if [ "$(id -u)" != "0" ]; then 
    echo "This script must be run as root" 1>&2 exit 1
  fi
}

function enable_disable_led {
    if [[ -z `cat /boot/config.txt | grep "dtparam=pwr_led_activelow=off"` ]]; then
        echo "Power LED Disabled. Please reboot $HOSTNAME to apply changes"
	echo -e "\n# Disable power led\ndtparam=pwr_led_activelow=off" >> /boot/config.txt
	cat /boot/config.txt | grep 'dtparam=pwr' --color=none
    else
	if [[ `cat /boot/config.txt | grep "dtparam=pwr_led_activelow=off"` == "dtparam=pwr_led_activelow=off" ]]; then 
	    echo "Power LED Enabled. Please reboot $HOSTNAME to apply changes"
	    sed -i s'/dtparam=pwr_led_activelow=off/#dtparam=pwr_led_activelow=off/'g /boot/config.txt 
	    cat /boot/config.txt | grep 'dtparam=pwr' --color=none
  	else
	    echo "Power LED Disabled. Please reboot $HOSTNAME to apply changes"
	    sed -i s'/#dtparam=pwr_led_activelow=off/dtparam=pwr_led_activelow=off/'g /boot/config.txt
	    cat /boot/config.txt | grep 'dtparam=pwr' --color=none
	fi
    fi
}

function main {
    check_root
    enable_disable_led
}

main
