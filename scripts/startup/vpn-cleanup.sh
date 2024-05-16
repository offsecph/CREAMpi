#!/bin/bash
# 
# vpntunnel cleanup script
# Cleanup the connection every 14400 seconds 
# (approx. every 4 hours)
#
LOG_DIR=/var/log/vpntunnel.log

TIMESTAMP() {
  date "+%Y-%m-%d %H:%M:%S"
}

c2_cleanup() {
  echo "[`TIMESTAMP`] Cleaning up vpn tunnel process.. " >> ${LOG_DIR}; sleep 2
  ps aux | grep "openvpn" | head -n1 | awk '{print $2}' | xargs -I % kill -9 %
  sleep 3
}

main() {
    c2_cleanup
}

main