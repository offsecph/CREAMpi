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

function configure_system() {
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
    
    sed -r -i "s/#NTP=/NTP=`curl -s https://www.ntppool.org/zone/tw | grep -E 'server\ ' | head -n1 | sed 's/\t//'g | cut -d' ' -f5`/" /etc/systemd/timesyncd.conf
    sed -r -i  's/#FallbackNTP=/FallbackNTP=/' /etc/systemd/timesyncd.conf
    timedatectl set-timezone "Asia/Taipei"
    timedatectl set-ntp true
    systemctl enable --now systemd-timesyncd
}

function configure_resolved() {
    if [[ `systemctl list-units --all -t service --full --no-legend "systemd-resolved.service" | sed 's/^\s*//g' | cut -f1 -d' '` != systemd-timesyncd.service ]]; then
        apt-get -qq install -y systemd-resolved
        apt remove -y resolvconf
    fi
    if [ ! -f /etc/systemd/resolved.conf.bak ]; then
        cp -fv /etc/systemd/resolved.conf /etc/systemd/resolved.conf.bak
    fi
    sed -r -i "s/#DNS=/DNS=1.1.1.1/" /etc/systemd/resolved.conf
    sed -r -i "s/#FallbackDNS=/FallbackDNS=9.9.9.9/" /etc/systemd/resolved.conf
    sed -r -i "s/#Domains=/Domains=dns.cloudflare.com dns.quad9.net/" /etc/systemd/resolved.conf
    sed -r -i "s/#DNSSEC=no/DNSSEC=yes/" /etc/systemd/resolved.conf
    sed -r -i "s/#DNSOverTLS=no/DNSOverTLS=yes/" /etc/systemd/resolved.conf

    apt remove -y resolvconf
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
    curl -sSf https://raw.githubusercontent.com/offsecph/CREAMpi/master/others/iptables.sh | bash
    
    if [ -f /etc/systemd/system/iptables-persitent.service ]; then
        rm -rf /etc/systemd/system/iptables-persistent.service
        wget https://raw.githubusercontent.com/offsecph/CREAMpi/master/services/iptables-persistent.service -P /etc/systemd/system
    fi
}

function enable_services() {
    systemctl enable systemd-resolved && sleep 3
    systemctl restart systemd-resolved
    systemctl enable --now iptables-persistent.service
    systemctl restart NetworkManager
}

function configure_lcd() {
    # Configure 3.5 inch LCD attached on CREAMpi
    LCD=yes
    if [ ! -d /opt/scripts/hardware/LCD-show-kali ]; then
        git clone https://github.com/lcdwiki/LCD-show-kali /opt/scripts/hardware 2
        chmod -R 755 /opt/scripts/hardware/LCD-show-kali
    fi

    # run LCD config if set to yes
    if [ ${LCD} == 'yes' ]; then
        /opt/scripts/hardware/LCD35-show
    fi    
}

function main() {
    status '[*] Fixing post installation configuration.. this may take a while.'
    configure_lcd
    configure_timesyncd
    configure_system
    configure_sshd
    configure_resolved
    configure_networkmanager
    configure_motd
    configure_raspitools
    configure_iptables
    enable_services
    configure_lcd
    status '\n[+] Done.'
}

main
