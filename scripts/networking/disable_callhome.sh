#!/bin/bash
#
# disable_callhome.sh - Disable callhome service
#
# callhome.service executes a reverse ssh tunnel on a remote server specified
#
# Note that the callhome.service must be installed on the system prior running the script.
#

function check_root {
  if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2 exit 1
  fi
}

function disable_callhome {
  if [ ! -f /opt/scripts/startup/callhome.sh ] && [ ! -f /etc/systemd/system/callhome.service ]
    then
      echo "callhome.service is not installed on $HOSTNAME"
      exit 1
  else
    echo -e "Disabling callhome.service.."
    systemctl disable --now callhome.service
    systemctl status callhome.service --no-pager
  fi
}

function main {
  check_root
  disable_callhome
}

main
