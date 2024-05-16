#!/bin/bash
# Configure stateful firewall allow only the SSH connection from port knocking sequence (69, 69, 69)

configure_iptables() {
    iptables -F

    # Allow traffic to loopback (C2 traffic as well)
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A OUTPUT -o lo -j ACCEPT

    # Configure stateful firewall
    iptables -A INPUT -m state --state INVALID -j DROP
    iptables -A OUTPUT -m state --state INVALID -j DROP

    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

    # Set policy to drop on input and output chains
    iptables -P INPUT DROP
    iptables -P OUTPUT DROP
}

enable_iptables_persistence() {
    mkdir -p /etc/iptables/ 2>/dev/null
    iptables-save > /etc/iptables/rules.v4
}

main() {
    configure_iptables
    enable_iptables_persistence
}

main
