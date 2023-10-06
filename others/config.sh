#!/bin/bash
# Raspberry pi - post installation config fix
#
# Add more post install config fix here:

# Fix eth0 to managed mode

function status() {
    echo -e "$@"
}

function networkmanager_managed() {
    rm -rf /etc/NetworkManager/NetworkManager.conf
    wget https://raw.githubusercontent.com/offsecph/CREAMpi/master/others/NetworkManager.conf -P /etc/NetworkManager/
    systemctl restart NetworkManager
    nmcli con del 'Ifupdown (eth0)'
    nmcli con mod 'Wired Connection 1' connection.id 'eth0'
    nmcli con up 'Wired Connection 1'
}

function main() {
    status '[*] Fixing NetworkManager to managed mode..'
    networkmanager_managed
    status '\n[+] Done.'
}

main
