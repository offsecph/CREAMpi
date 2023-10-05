#!/bin/bash
#
# enables / disables Bluetooth hardware lock when powered on
#
# Hardware locks persist only across reboots.
#

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
