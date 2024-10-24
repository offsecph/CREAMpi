#!/bin/bash
#
# httpswrapper cleanup script
# Cleanup the connection every 259200 seconds
# (approx. every 72 hours)
#
LOG_DIR=/var/log/httpswrapper.log

TIMESTAMP() {
  date "+%Y-%m-%d %H:%M:%S"
}

hwrap_cleanup() {
  echo "[`TIMESTAMP`] Cleaning up httpswrapper  process.. " >> ${LOG_DIR}; sleep 2
  ps aux | grep "httpswrapper" | head -n1 | awk '{print $2}' | xargs -I % kill -9 %
  sleep 1
}

hwrap_start() {
    systemctl restart httpswrapper.service
}

main() {
    hwrap_cleanup
    hwrap_start
}

main
