#!/bin/bash
# 
# sshtunnel cleanup script
# Cleanup the connection every 259200 seconds
# (approx. every 72 hours)
#
LOG_DIR=/var/log/sshtunnel.log

TIMESTAMP() {
  date "+%Y-%m-%d %H:%M:%S"
}

c2_cleanup() {
  echo "[`TIMESTAMP`] Cleaning up ssh tunnel process.. " >> ${LOG_DIR}; sleep 2
  ps aux | grep "ssh -L" | head -n1 | awk '{print $2}' | xargs -I % kill -9 %
  sleep 1
}

main() {
    c2_cleanup
}

main