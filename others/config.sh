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
}

function configure_resolved() {
    if [[ `systemctl list-units --all -t service --full --no-legend "systemd-resolved.service" | sed 's/^\s*//g' | cut -f1 -d' '` != systemd-timesyncd.service ]]; then
        apt-get -qq install -y systemd-resolved
    fi
    if [ ! -f /etc/systemd/resolved.conf.bak ]; then
        cp -fv /etc/systemd/resolved.conf /etc/systemd/resolved.conf.bak
    fi
    rm -rf /etc/systemd/resolved.conf
    cat > /etc/systemd/resolved.conf << EOF
#  This file is part of systemd.
#
#  systemd is free software; you can redistribute it and/or modify it under the
#  terms of the GNU Lesser General Public License as published by the Free
#  Software Foundation; either version 2.1 of the License, or (at your option)
#  any later version.
#
# Entries in this file show the compile time defaults. Local configuration
# should be created by either modifying this file, or by creating "drop-ins" in
# the resolved.conf.d/ subdirectory. The latter is generally recommended.
# Defaults can be restored by simply deleting this file and all drop-ins.
#
# Use 'systemd-analyze cat-config systemd/resolved.conf' to display the full config.
#
# See resolved.conf(5) for details.

[Resolve]
# Some examples of DNS servers which may be used for DNS= and FallbackDNS=:
# Cloudflare: 1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com 2606:4700:4700::1111#cloudflare-dns.com 2606:4700:4700::1001#cloudflare-dns.com
# Google:     8.8.8.8#dns.google 8.8.4.4#dns.google 2001:4860:4860::8888#dns.google 2001:4860:4860::8844#dns.google
# Quad9:      9.9.9.9#dns.quad9.net 149.112.112.112#dns.quad9.net 2620:fe::fe#dns.quad9.net 2620:fe::9#dns.quad9.net
DNS=1.1.1.1 9.9.9.9
FallbackDNS=8.8.8.8
Domains=dns.cloudflare.com dns.quad9.net dns.google
DNSSEC=yes
DNSOverTLS=yes
#MulticastDNS=yes
#LLMNR=yes
#Cache=yes
#CacheFromLocalhost=no
#DNSStubListener=yes
#DNSStubListenerExtra=
#ReadEtcHosts=yes
#ResolveUnicastSingleLabel=no
#StaleRetentionSec=0
EOF
}

function configure_networkmanager() {
    rm -rfv /etc/NetworkManager/NetworkManager.conf
    wget https://raw.githubusercontent.com/offsecph/CREAMpi/master/others/NetworkManager.conf -P /etc/NetworkManager/
    nmcli con del 'Ifupdown (eth0)'
    if [[ `nmcli con show | tail -n1 | cut -d' ' -f1` != eth0 ]] \
        || [[ `nmcli con show | tail -n1 | cut -d' ' -f1` != 'Ifupdown (eth0)' ]]; then
        :
    else
        nmcli con show | tail -n1 | awk '{print $2}' | xargs -I % nmcli con del %
    fi
}

function configure_motd() {
    if [ ! -f /etc/motd.bak ]; then  
        cp -vf /etc/motd /etc/motd.bak
    fi
    rm -rf /etc/motd
    wget https://raw.githubusercontent.com/offsecph/CREAMpi/master/others/motd -P /etc/
}

function configure_raspitools() {
    if [ ! -f /usr/bin/vcgencmd ]; then
        pip install setuptools
        pip install git+https://github.com/nicmcd/vcgencmd.git
    fi
    if [ -f /usr/games/lolcat ]; then
        mv -vf /usr/games/lolcat /usr/bin
    fi
}

function configure_iptables() {
    if [ ! -f /etc/systemd/iptables-persistent.service ]; then
        curl -sSf https://raw.githubusercontent.com/offsecph/CREAMpi/master/others/iptables.sh | bash
        wget https://raw.githubusercontent.com/offsecph/CREAMpi/master/services/iptables-persistent.service -P /etc/systemd/system
    fi
}

function enable_services() {
    systemctl enable systemd-resolved && sleep 2
    systemctl restart systemd-resolved
    systemctl enable --now systemd-timesyncd
    systemctl enable --now iptables-persistent.service
    systemctl restart NetworkManager
}

function main() {
    status '[*] Fixing post installation configuration'
    update_system
    configure_sshd
    configure_timesyncd
    configure_resolved
    configure_networkmanager
    configure_motd
    configure_raspitools
    configure_iptables
    enable_services
    status '\n[+] Done.'
}

main
