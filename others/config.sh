#!/bin/bash
# Raspberry pi - post installation config fix
#
# Add more post install config fix here:

# Fix eth0 to managed mode


if [ "$EUID" -ne 0 ] ;then
    echo "Please download and run this script as root"
    exit 1
fi

function status() {
    echo -e "$@"
}

function update_system() {
    apt-get -qq update -y
}

function configure_sshd() {
    sed -i -e 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
    systemctl restart ssh
}

function configure_timesyncd() {
    if [[ `systemctl list-units --all -t service --full --no-legend "systemd-timesyncd.service" | sed 's/^\s*//g' | cut -f1 -d' '` != systemd-timesyncd.service ]]; then
        apt-get -qq install -y systemd-timesyncd
    fi
    timedatectl set-timezone "Asia/Manila"
    timedatectl set-ntp true
    systemctl enable --now systemd-timesyncd
}

function configure_resolved() {
    if [[ `systemctl list-units --all -t service --full --no-legend "systemd-resolved.service" | sed 's/^\s*//g' | cut -f1 -d' '` != systemd-timesyncd.service ]]; then
        apt-get -qq install -y systemd-resolved
    fi
    sed -e -i s'/#DNS=/DNS=1.1.1.1 9.9.9.9/' /etc/systemd/resolved.conf
    sed -e -i s'/#Domains/Domains=dns.cloudflare.com dns.quad9.net/' /etc/systemd/resolved.conf
    systemctl enable --now systemd-resolved
}

function configure_networkmanager() {
    rm -rfv /etc/NetworkManager/NetworkManager.conf
    wget https://raw.githubusercontent.com/offsecph/CREAMpi/master/others/NetworkManager.conf -P /etc/NetworkManager/
    systemctl restart NetworkManager
    nmcli con del 'Ifupdown (eth0)'
    if [[ `nmcli con show | tail -n1 | cut -d' ' -f1` != eth0 ]] \
        || [[ `nmcli con show | tail -n1 | cut -d' ' -f1` != 'Ifupdown (eth0)' ]]; then
        :
    else
        nmcli con show | tail -n1 | awk '{print $2}' | xargs -I % nmcli con del %
    fi
}

function configure_motd() {
    mv -v /etc/motd /etc/motd.bak
    wget https://raw.githubusercontent.com/offsecph/CREAMpi/master/others/motd -P /etc/
}

function configure_raspitools() {
    pip install setuptools
    pip install git+https://github.com/nicmcd/vcgencmd.git
}

function configure_iptables() {
    curl -sSf https://raw.githubusercontent.com/offsecph/CREAMpi/master/others/iptables.sh | bash
    wget https://raw.githubusercontent.com/offsecph/CREAMpi/master/services/iptables-persistent.service -P /etc/systemd/system
    systemctl enable --now iptables-persistent.service
}

function main() {
    status '[*] Fixing post installation configuration'
    configure_sshd
    configure_timesyncd
    configure_resolved
    configure_networkmanager
    configure_motd
    configure_raspitools
    configure_iptables
    status '\n[+] Done.'
}

main
