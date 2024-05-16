#!/bin/bash
#
# Starts openvpn to connect to remote host
# this script is managed by vpntunnel.service in /etc/systemd/system
#
#
# Setting Up:
# - generate an ovpn file from the vpn server
# - sudo pivpn add nopass --name dropbox
# - upload the ovpn file here in /root/.ovpn
#
# VPN reverse tunnel configuration
#
# Below config will connect to the remote server.
# a reverse vpn tunnel to connect back to this host
# and reach hosts that are connected also on the vpn
# server 
#
# WARNING: This host will not connect if openVPN service
# is not running on the server

# The server which the keycroc will connect to
OVPN_FILE="/root/.ovpn/dropbox.ovpn"

# Logging
# the host will try to connect to the remote server time by time. logs are located in
# /var/log/vpntunnel.log to debug, verify the connection.
LOG_DIR=/var/log/vpntunnel.log

# Logging timestamp function
TIMESTAMP() {
  date "+%Y-%m-%d %H:%M:%S"
}

c2_vpntunnel() {
  echo "[`TIMESTAMP`] Service started.." >> ${LOG_DIR} ; sleep 2 
  echo "[`TIMESTAMP`] Setting up reverse VPN tunnel to dedicated vpn server" >> ${LOG_DIR}
  echo "[`TIMESTAMP`] Connecting vpn client to vpn server.." >> ${LOG_DIR}
  openvpn --config ${OVPN_FILE} & disown
  sleep 2

  CHECK_CON=`ifconfig tun0 | grep inet | awk '{print $2}'`

  if [[ $CHECK_CON != "" ]]; then
    echo "[`TIMESTAMP`] Successfully established reverse vpn tunnel on the remote server got an IP of (${CHECK_CON}).." >> ${LOG_DIR}
  else
    echo "[`TIMESTAMP`] ERROR: VPN reverse tunnel failed. Unable to connect to the remote server.." >> ${LOG_DIR}
  fi
}

main() {
    c2_vpntunnel
}

main