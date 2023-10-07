#!/bin/bash
# Configure stateful firewall allow only the SSH tunnel and local class C networks

function configure_iptables() {
    iptables -F

    # Allow traffic to loopback (C2 traffic as well)
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A OUTPUT -o lo -j ACCEPT

    # Allow incoming connections from wlan0 and Class C local management
    iptables -A INPUT -p tcp --dport 22 -m state --state NEW -s 192.168.1.1 -j ACCEPT
    iptables -A INPUT -p tcp --dport 22 -m state --state NEW -s 192.168.0.1 -j ACCEPT
    iptables -A INPUT -p tcp --dport 22 -m state --state NEW -s 192.168.0.0/16 -j ACCEPT

    # Configure stateful firewall
    iptables -A INPUT -m state --state INVALID -j DROP
    iptables -A OUTPUT -m state --state INVALID -j DROP

    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

    # Set policy to drop on input and output chains
    iptables -P INPUT DROP
    iptables -P OUTPUT DROP
}

function enable_iptables_persistence() {
    mkdir -p /etc/iptables/ 2>/dev/null
    iptables-save > /etc/iptables/rules.v4
    systemctl enable --now iptables
}

function main {
    configure_iptables
    enable_iptables_persistence
}

main
