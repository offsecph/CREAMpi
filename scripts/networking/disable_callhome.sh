#!/bin/bash
#
# disable_callhome.sh - Disable callhome service
#
# callhome.service executes a reverse ssh tunnel on a remote server specified
#
# Note that the callhome.service must be installed on the system prior running the script.
#

function main {
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

main
