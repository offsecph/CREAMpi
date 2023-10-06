#!/bin/bash
# Raspberry pi - post installation config fix
#
# Add more post install config fix here:

# Fix eth0 to managed mode

function status() {
    echo -e "$@"
}

function networkmanager_managed() {
    rm -rfv /etc/NetworkManager/NetworkManager.conf
    wget https://raw.githubusercontent.com/offsecph/CREAMpi/master/others/NetworkManager.conf -P /etc/NetworkManager/
    systemctl restart NetworkManager
    nmcli con del 'Ifupdown (eth0)'
}

function main() {
    status '[*] Fixing NetworkManager to managed mode..'
    networkmanager_managed
    status '\n[+] Done.'
}

main
