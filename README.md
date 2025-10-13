# C.R.E.A.M.pi - Raspberry pi Network Implant

 ***C.R.E.A.M.pi*** is short for (Cyber Reconnaissance and Exploitation Analysis Module Pi) is a pentest dropbox which will be shipped to the customer / client. This can be also used in opportunistic testing approach (Red Teaming) as hardware implants. C.R.E.A.M.pi will either connect from an ethernet port where it is connected from the client's network (in band connection) or over a portable Wifi network (out of band connection). C.R.E.A.M.pi will automatically connect to the server hosted on the cloud which we control.

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

- Create a minimal installation image of kali rpi from kali build scripts
- Flash the minimal image of raspberry pi on SD card and run the device
- Run `ansible-playbook main.yml` to provision base install of CREAMpi

```
Supported Hardware Versions:
- Raspberry pi 4B
- Raspberry pi 5
```

---
### NEW UPDATE:

```
v.1.3
10/13/2025 - Added tailscaled for managed tailscale VPN service connection
```

---
### UPDATE:

```
v1.1
09/11/2024 - ecryptfs-utils is deprecated from repository and is not supported anymore.
           - Added bloodhound-ce ingestor
           - Added sliver server (as download only)
           - Added metasploit framework
           - Added repo tools:
                * smbmap
                * hashcat
                * python2
                * seclists
                * wordlists
                * python2-pip

```
```
v1.2
           - Added httpsWrapper for SSH over TLS tunneling
           - Added sliver-server (full install) CREAMpi as teamserver
           - Added example templates for inventory on data/examples for VPN and SSH connections
           - Added example templates for ansible main.yml to pick an installation:
                * full-install.yml
                * advanced-install.yml
                * basic-install.yml
```

--- 
### Accessing CREAMpi via SSH after provisioning

```
CREAMpi stateful firewall is enabled by default. Knock on port sequence to access server via ssh.
```

Open the port:
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
;;  `remote_server` is the remote c2 server which CREAMpi will connect (IP or domain name)
;;  `tunnel_port` is used in changing ssh tunnel configuration port
;;  `monitor_port` is used for monitoring ssh tunnel data (0 to disable monitoring and port usage)
;;  `httpswrapper_port` is used to open a local socket for HTTPS tunnel that will be used for SSH tunneling
;;  `httpstun_port` is used in changing the ssh tunnel configuration in httpstun (SSH over HTTPS)
;;  `tunnel_service` is used to declare what default tunneling service will be enabled (values:ssh, vpn)
;;  `key_file` is the ssh key file from the files directory for uploading and used as ssh key.
;;  `ovpn_file` is the ovpn file from the files directory for uploading and used as vpn key.
;;  `tailscale_authkey` is the auth access token to join the CREAMpi on managed tailscale VPN service
;;  `mount_phrase` will be used to configure ecryptfs passphrase for folder encryption (DEPRECATED)

[creampi]
192.168.1.249	 hostname='' tunnel_port='' monitor_port='0' httpswrapper_port='' httpstun_port='' ovpn_file=''
;192.168.1.250    hostname='' tunnel_port='' monitor_port='0' httpswrapper_port='' httpstun_port='' ovpn_file=''
;
;; mount_phrase is deprecated due to ecryptfs not supported anymore in debian systems
;;192.168.1.251    hostname='' tunnel_port='' monitor_port='0' httpswrapper_port='' httpstun_port='' mount_phrase='' ovpn_file=''

;; [hosts:vars] will use the same configuration for all raspberry pi for provisioning.
;; to set a different values per server, remove vars below and align them above along
;; with the hostname or IP address of the server
;; if using vpn, upload an ssh key still for a backup connection although it will not
;; be used as a tunneling provider
[creampi:vars]
root_password=''
user_password=''
remote_user=''
remote_server=''
tunnel_service=''
key_file=''
tailscale_authkey=''
```

4. Customize installation and copy example files from ansible/examples directory to ansible root directory and rename it as `main.yml`
```
cp /path/to/CREAMpi/ansible/examples/full-install.yml /path/to/CREAMpi/ansible/main.yml
```

5. Run ansible playbook with default user name and password of kali installation and wait for provisioning.
```sh
ansible-playbook main.yml --extra-vars "ansible_user=kali ansible_password=kali"
```

6. Use extra vars to use a default tunneling protocol or add it on creampi:vars
```sh
ansible-playbook main.yml --extra-vars "ansible_user=kali ansible_password=kali tunnel_service=vpn"
```
*or*
```sh
ansible-playbook main.yml --extra-vars "ansible_user=kali ansible_password=kali tunnel_service=ssh"
```

7. Have a coffee break! ☕

---
### NEW: TAILSCALE VPN Service
```
Tailscale is a zero-config peer-to-peer VPN built on top of wireguard and is enabled by default
on `advanced` and `full` installations. It creates a virtual private
network between devices allowing to communicate securely without poking holes within firewalls, NAT
or different networks. 

Requirements:
1. A Tailscale web account for managing devices
2. Tailscale Auth Key
```

---
### SSH over TLS traffic: Connecting to C2

```
SSH tunneling over TLS is enabled by default on `advanced` and `full` installations
upon provisioning when ssh tunnel provider is selected. A few requirements on 
the server side to automatically establish a SSH/TLS tunnel to the remote 
server.

Requirements:
1. A domain name and domain dns configured
2. Server side (c2) must be configured to handle nginx https reverse proxy to ssh
3. Private key of the remote server to be able to connect (must be uploaded 
to files/ directory before provisioning)
```

Sample configuration on Server side (VPS)

```nginx
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

# Mandatory "events" block
events {
    worker_connections 1024;
}

stream {
    upstream ssh {
        server 127.0.0.1:22;
    }

    map $ssl_preread_protocol $upstream {
        default ssh;
    }

    server {
        listen 443 ssl; # Listen on HTTPS port
        server_name {YOUR_DOMAIN};

        # Path to your SSL certificate and key
        ssl_certificate     /path/to/your/tls_certificate/fullchain.pem;
        ssl_certificate_key /path/to/your/tls_certificate_key/privkey.pem;

        ssl_protocols       TLSv1.2 TLSv1.3;
        ssl_ciphers         HIGH:!aNULL:!MD5;

        ssl_stapling on;
        ssl_stapling_verify on;

        ssl_preread on;
        proxy_pass ssh; # Forward traffic to the upstream SSH server
    }
}
```

---
### VPN setup: Connecting to C2

```
OpenVPN tunneling is Enabled by default on all types of installation upon 
provisioning when vpn tunnel provider is selected. An OpenVPN server is 
required to perform such actions and request .ovpn file for the client.

Requirements:
1. An openvpn server setup with .ovpn file
2. .ovpn file must be uploaded to /files directory before provisioning
```

*[Openvpn server installation guide](https://www.digitalocean.com/community/tutorials/how-to-set-up-and-configure-an-openvpn-server-on-ubuntu-20-04)*

---
### Troubleshooting:
Legend:
- *[STALLS] - slowing down or stalling ansible in controller.*
- *[ERRORS] - introducing some errors upon script execution.*
- *[PERFORMANCE] - it affects the performance of the pi when executed.*

Monitoring Execution:
```b
To monitor execution on the pi if ansible process hangs on the controller, you can ssh
in to the pi and execute these commands:
```
```bash
while true; do ps aux | grep python3 && sleep 1 && clear; done
```

Known Issues:

- *ansible [STALLS] when trying to update and upgrade apt repository*
- *ansible [STALLS] when trying to install netexec (pipx netexec)*
- *ansible [STALLS] when trying to install sliver c2*
- *ansible [STALLS] when trying to install metasploit*
- *ansible [ERRORS] on installing netexec (pipx netexec)*
```
Just re-run the ansible playbook.
```

*[STALLS] Ansible stalls in a certain point of the installation*
```
Ansible runs on python, so it uses paramiko and other ssh modules to execute and provision
the target. It might be that the python process has been exited uncleanly or a network issue
had happened.

Ansible is idempotent. Just re-run the ansible playbook again.
```

*[PERFORMANCE] Slow installation time for sliver c2 / raspberry pi slows down*
```
go is building from source for arm64 in the background any may affect the performance of the CPU. 
This may introduce errors in installing every other provisioning assets on the CREAMpi. 
You may disable `import_playbook` of `sliver-server.yml` if you want to install manually.
```

*[STALLS] Too long installation time for netxec (pipx netexec)*
```
pipx compiles all the source code from repo to build netexec.
this may cause long install time, introduce errors of such. You may install this manually 
if you like, but this should complete if no errors in the network or in 
installing the os. If it stalls or hangs, just refer to the above known issues section.
```

*[STALLS] Too long installation time for metasploit (msf framework)*
```
Same with go, it has tons of packages being installed as c2 framework so you may manually 
install or not install it if you would like. Refer to the above known issues section.
```

*[ERRORS] ansible errors upon gathering facts*
```
The message: `FAILED! => {"msg": "Timeout (12s) waiting for privilege escalation prompt: "}` 
is when you terminate the session of running instance of ansible playbook. 
Wait for at least 1 minute before re-executing again.
```

*[ERRORS] I rerun the script, netexec still fails to install*
```
install it manually on the CREAMpi by running:

`pipx install git+https://github.com/Pennyw0rth/NetExec`

if it the error still persist; like `[fatal error: Python.h: No such file or directory]` 
the cause is might be a unexpected termination of ansible process which broke down the 
python environment. Reimage pi, and rerun ansible playbook.
```

*[DEBUGGING] For debugging any errors per playbook:*
```
- go to ansible/
- comment everything out `import_playbook`
- uncomment `import_playbook` of a module that needs to be run or troubleshoot.
- run the ansible playbook.
```

---
### Required: Building kali raspberry pi minimal via kali build scripts

***Running on raspbery pi os or previous kali raspberry pi or CREAMpi image***

```
To make the image headless, meaning it will not chomp down all of the raspberry pi resources 
(since it has gui), follow the procedures below:
```

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

- https://www.kali.org/docs/development/arm-build-scripts/
- https://ansible.readthedocs.io/projects/lint/rules/no-changed-when/
- https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html
- https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_checkmode.html
- https://www.redhat.com/en/blog/ansible-galaxy-intro
- https://docs.ansible.com/ansible/latest/cli/ansible-galaxy.html
- https://nginx.org/en/docs/stream/ngx_stream_ssl_preread_module.html
- https://tailscale.com/kb/1031/install-linux