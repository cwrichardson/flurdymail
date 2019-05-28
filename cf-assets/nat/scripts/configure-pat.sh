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

REGION=$(curl -sq http://169.254.169.254/latest/meta-data/placement/availability-zone/)
REGION=${REGION: :-1}

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

EXT_SUBNET=$(aws ec2 describe-instances \
            --region $REGION \
            --instance-id $INSTANCE_ID \
            --query "Reservations[*].Instances[].SubnetId" \
            --output text)
INT_SUBNET=$(grep $EXT_SUBNET /tmp/subnetmap | cut -f2 -d" ")

INT_CIDR=$(aws ec2 describe-subnets --region $REGION --subnet-ids $INT_SUBNET --output text | grep ^SUBNETS | cut -f6)

log "Enabling PAT..."
sysctl -q -w net.ipv4.ip_forward=1 net.ipv4.conf.eth0.send_redirects=0 && 
(
	firewall-cmd --zone=public \
	    --add-rich-rule='rule family=ipv4 masquerade' --permanent &&
	firewall-cmd --zone=external --add-interface=eth0 --permanent &&
	firewall-cmd --zone=internal --add-source=$INT_CIDR --permanent
    ) ||
die

firewall-cmd --reload

sysctl net.ipv4.ip_forward net.ipv4.conf.eth0.send_redirects | log
# iptables -n -t nat -L POSTROUTING | log

log "Configuration of PAT complete."
exit 0
