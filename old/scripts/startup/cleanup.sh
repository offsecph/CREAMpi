#!/bin/bash
# 
# Callhome cleanup script
# Cleanup the connection every 86400 seconds
#
LOG_DIR=/var/log/callhome.log

TIMESTAMP() {
  date "+%Y-%m-%d %H:%M:%S"
}

c2_cleanup() {
  echo "[`TIMESTAMP`] Cleaning up command and control process.. " >> ${LOG_DIR}; sleep 2
  ps aux | grep "ssh -L" | head -n1 | awk '{print $2}' | xargs -I % kill -9 %
  sleep 3
}

main() {
    c2_cleanup
}

main