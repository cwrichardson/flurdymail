#!/bin/bash
# Configure the instance to run as a Port Address Translator (PAT) to provide
# Internet connectivity to private instances.

function log { logger -s -t "vpc" -- $1; }

function die {
    [ -n "$1" ] && log "$1"
    log "Configuration of PAT failed!"
    exit 1
}

# Sanitize PATH
export PATH="/usr/sbin:/sbin:/usr/bin:/bin"

log "Determining the MAC address on eth0..."
ETH0_MAC=$(cat /sys/class/net/eth0/address) ||
    die "Unable to determine MAC address on eth0."
log "Found MAC ${ETH0_MAC} for eth0."

# This script is intended to run only on a NAT instance for a VPC
# Check if the instance is a VPC instance by trying to retrieve vpc id
VPC_ID_URI="http://169.254.169.254/latest/meta-data/network/interfaces/macs/${ETH0_MAC}/vpc-id"

VPC_ID=$(curl --retry 3 --silent --fail ${VPC_ID_URI})
if [ $? -ne 0 ]; then
   log "The script is not running on a VPC instance. PAT may masquerade traffic for Internet hosts!"
fi

log "Enabling PAT..."
sysctl -q -w net.ipv4.ip_forward=1 net.ipv4.conf.eth0.send_redirects=0 && 
(
    iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2> /dev/null ||
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE ) ||
die

sysctl net.ipv4.ip_forward net.ipv4.conf.eth0.send_redirects | log
iptables -n -t nat -L POSTROUTING | log

log "Configuration of PAT complete."
exit 0
