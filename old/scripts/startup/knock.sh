#!/bin/bash
# Check for operation state of network interfaces and ensure that knockd aligns with the interfaces.
# 
# If both interfaces are up, it will knockd will set to wired connection instead of wireless.

interface0=eth0
interface1=wlan0
interface2=eth1

class_net=/sys/class/net

check_operstate() {
    # If a third interface is present
    if [[ -d /sys/class/net/${interface2} ]]; then
        # Check operstate per interface
        interface0_state=`cat ${class_net}/${interface0}/operstate`
        interface1_state=`cat ${class_net}/${interface1}/operstate`
        interface2_state=`cat ${class_net}/${interface2}/operstate`

        # If one of the interfaces is up, set specific interface to add to knockd configuration
        if [[ ${interface0_state} == 'up' ]] && \
        [[ ${interface1_state} == 'down' ]] && \
        [[ ${interface2_state} == 'down' ]]; then
            sed -i s"/interface =.*/interface = ${interface0}/" /etc/knockd.conf
        elif [[ ${interface0_state} == 'down' ]] && \
        [[ ${interface1_state} == 'up' ]] && \
        [[ ${interface2_state} == 'down' ]]; then
            sed -i s"/interface =.*/interface = ${interface1}/" /etc/knockd.conf
        elif [[ ${interface0_state} == 'down' ]] && \
        [[ ${interface1_state} == 'down' ]] && \
        [[ ${interface2_state} == 'up' ]]; then
            sed -i s"/interface =.*/interface = ${interface2}/" /etc/knockd.conf
        # If three interfaces are up, prioritize the default wired interface
        # If two wired interfaces are up, prioritize default interface
        elif [[ ${interface0_state} == 'up' ]] && \
        [[ ${interface1_state} == 'up' ]] && \
        [[ ${interface2_state} == 'up' ]]; then
            sed -i s"/interface =.*/interface = ${interface0}/" /etc/knockd.conf
        elif [[ ${interface0_state} == 'down' ]] && \
        [[ ${interface1_state} == 'up' ]] && \
        [[ ${interface2_state} == 'up' ]]; then
            sed -i s"/interface =.*/interface = ${interface2}/" /etc/knockd.conf
        elif [[ ${interface0_state} == 'up' ]] && \
        [[ ${interface1_state} == 'down' ]] && \
        [[ ${interface2_state} == 'up' ]]; then
            sed -i s"/interface =.*/interface = ${interface0}/" /etc/knockd.conf
        elif [[ ${interface0_state} == 'up' ]] && \
        [[ ${interface1_state} == 'up' ]] && \
        [[ ${interface2_state} == 'down' ]]; then
            sed -i s"/interface =.*/interface = ${interface0}/" /etc/knockd.conf
        fi
    else
        # Check operstate per interface
        interface0_state=`cat ${class_net}/${interface0}/operstate`
        interface1_state=`cat ${class_net}/${interface1}/operstate`
        
        # If one default interface is up, set specific interface to add to knockd configuration
        if [[ ${interface0_state} == 'up' ]] && \
        [[ ${interface1_state} == 'down' ]]; then
            sed -i s"/interface =.*/interface = ${interface0}/" /etc/knockd.conf
        elif [[ ${interface0_state} == 'down' ]] && \
        [[ ${interface1_state} == 'up' ]]; then
            sed -i s"/interface =.*/interface = ${interface1}/" /etc/knockd.conf
        # If both interfaces are up, give priority to wired networking
        elif [[ ${interface0_state} == 'up' ]] && \
        [[ ${interface1_state} == 'up' ]]; then
            sed -i s"/interface =.*/interface = ${interface0}/" /etc/knockd.conf
        fi
    fi


}

restart_knockd() {
    systemctl restart knockd.service
    sleep 1
    exit 0
}

main() {
    check_operstate
    restart_knockd
}

main