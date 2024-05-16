# C.R.E.A.M.pi - Raspberry pi kali dropbox

 **C.R.E.A.M.pi** is short for (Cyber Reconnaissance and Exploitation Analysis Module Pi) is a pentest dropbox which will be shipped to the customer / client. C.R.E.A.M.pi will either connect from an ethernet port where it is connected from the client's network (in band connection) or over a portable Wifi network (out of band connection). C.R.E.A.M.pi will automatically connect to the server hosted on the cloud which we control.

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
```
---
## Provision CREAMpi via Ansible

- Flash minimal installation of kali raspberry pi minimal on balena etcher
- Run ansible-playbook `main.yml` to provision base install of CREAMpi 

---
### Accessing CREAMpi via SSH after provisioning

CREAMpi stateful firewall is enabled by default. Knock on port sequence to access
ssh configuration.
```sh
knock <CREAMpi-IP> 69 69 69 -d 500
ssh username@CREAMpi
```
To close the port:
```sh
knock <CREAMpi-IP> 96 96 96 -d 500
```

--- 
### Installation instructions *(requires internet connection)*

This will:
  - Provision CREAMpi config on multiple pi devices on a single run

1. Set the ssh key of the remote server on files directory. This will be also be used as backup key and primary SSH key
```sh
cp id_rsa CREAMpi/files/id_rsa
```
2. Set the ovpn file on files directory if openvpn service is going to be used as VPN key file
```sh
cp dropbox.ovpn CREAMPi/files/dropbox.ovpn
```

3. Configure vars config on data/inventory
```
;; Set the ansible_user as default credentials to connect to raspberry pi
;; Set the ansible_password as default credentials to connect to raspberry pi
;; Set vars:
;;  `ansible_user` is used to use default user of ansible remote host
;;  `ansible_password` is used to use default password of ansible remote user
;;  `root_password` is used to provision new root password for CREAMpi
;;  `user_password` is used to provision new kali password for CREAMpi
;;  `hostname` is used to provision host names on target raspberry pi systems
;;  `remote_user` is the remote user that will use the ssh key to connect to remote c2 server
;;  `remote_server` the remote c2 server which CREAMpi will connect
;;  `tunnel_port` is used in changing ssh tunnel configuration port
;;  `monitor_port` is used for monitoring ssh tunnel data (0 to disable monitoring and port usage)
;;  `tunnel_service` is used to declare what default tunneling service will be enabled (values:ssh, vpn)
;;  `key_file` is the ssh key file from the files directory for uploading and used as ssh key.
;;  `ovpn_file` is the ovpn file from the files directory for uploading and used as vpn key.
;;  `mount_phrase` will be used to configure ecryptfs passphrase for folder encryption
[creampi]
192.168.1.250     hostname='CREAMpi5-zero' tunnel_port='2222' monitor_port='0' mount_phrase='' ovpn_file=''
;192.168.1.251    hostname='CREAMpi4-one' tunnel_port='2223' monitor_port='0' mount_phrase='' ovpn_file=''

;; [hosts:vars] will use the same configuration for all raspberry pi for provisioning.
;; to set a different values per server, remove vars below and align them above along
;; with the hostname or IP address of the server
[creampi:vars]
root_password=''
user_password=''
remote_user=''
remote_server=''
tunnel_service=''
key_file=''
```

4. Run ansible playbook with default user name and password of kali installation and wait for provisioning.
```sh
ansible-playbook main.yml --extra-vars "ansible_user=kali ansible_password=kali"
```
5. Use extra vars to use a default tunneling protocol or add it on creampi:vars
```sh
ansible-playbook main.yml --extra-vars "ansible_user=kali ansible_password=kali tunnel_service=vpn"
```
*or*
```sh
ansible-playbook main.yml --extra-vars "ansible_user=kali ansible_password=kali tunnel_service=ssh"
```
6. Have a coffee break! ☕

---
### Build kali raspberry pi minimal via kali build scripts

***Running on raspbery pi os or previous kali raspberry pi or CREAMpi image***

1. Download kali raspberry pi build scripts from gitlab
```sh
git clone https://gitlab.com/kalilinux/build-scripts/kali-arm
```
2. Run build_deps.sh for preparing the image
```sh
cd kali-arm 
sudo ./common.d/build_deps.sh
```
3. Reboot and run the kali raspberry pi image builder (may take up to 20 mins to 30 mins depending on internet connection)
```
sudo ./raspberry-pi.sh --arch arm64 --minimal
```
3. For raspberry pi 5 versions
```
sudo ./raspberry-pi5.sh --arch arm64 --minimal
```
4. Transfer newly created image file to your host machine for flashing

***Running on x86_64 systems*** 

1. Download kali raspberry pi build scripts from gitlab
```sh
git clone https://gitlab.com/kalilinux/build-scripts/kali-arm
```
2. Run build_deps.sh for preparing the image
```sh
cd kali-arm 
sudo ./common.d/build_deps.sh
```
3. Reboot and run the kali raspberry pi image builder (may take up to 20mins to 30mins depending on internet connection)
```
sudo ./raspberry-pi.sh --arch arm64 --minimal
```
3. For raspberry pi 5 versions
```
sudo ./raspberry-pi5.sh --arch arm64 --minimal
```
4. After the script finishes running, you will have an image file located in ~/kali-arm/images/
5. Transfer newly created image file to your host machine for flashing

---

## Resources:
https://www.linuxtechi.com/replace-strings-lines-with-ansible/
https://ansible.readthedocs.io/projects/lint/rules/no-changed-when/
https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_checkmode.html