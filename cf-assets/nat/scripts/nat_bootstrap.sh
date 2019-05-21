#!/bin/bash -e
# NAT Bootstrapping
# authors: tonynv@amazon.com, sancard@amazon.com, ianhill@amazon.com, 
# cwr@mirovoysales.com
# NOTE: This requires GNU getopt. On Mac OS X and FreeBSD you must
# install GNU getopt and mod the checkos function so that it's supported


# Configuration
PROGRAM='Linux NAT'

##################################### Functions Definitions
function checkos () {
    platform='unknown'
    unamestr=`uname`
    if [[ "${unamestr}" == 'Linux' ]]; then
        platform='linux'
    else
        echo "[WARNING] This script is not supported on MacOS or FreeBSD"
        exit 1
    fi
    echo "${FUNCNAME[0]} Ended"
}

function usage() {
    echo "$0 <usage>"
    echo " "
    echo "options:"
    echo -e "--help \t Show options for this script"
    echo -e "--banner \t Enable or Disable Bastion Message"
    echo -e "--enable \t SSH Banner"
    echo -e "--tcp-forwarding \t Enable or Disable TCP Forwarding"
    echo -e "--x11-forwarding \t Enable or Disable X11 Forwarding"
}

function osrelease () {
    OS=`cat /etc/os-release | grep '^NAME=' |  tr -d \" | sed 's/\n//g' | sed 's/NAME=//g'`
    if [[ "${OS}" == "Ubuntu" ]]; then
        echo "Ubuntu"
    elif [[ "${OS}" == "Amazon Linux AMI" ]] || [[ "${OS}" == "Amazon Linux" ]]; then
        echo "AMZN"
    elif [[ "${OS}" == "CentOS Linux" ]]; then
        echo "CentOS"
    elif [[ "${OS}" == "SLES" ]]; then
        echo "SLES"
    else
        echo "Operating System Not Found"
    fi
    echo "${FUNCNAME[0]} Ended" >> /var/log/cfn-init.log
}


function setup_cron () {
    echo "${FUNCNAME[0]} Started"

    if [[ "${release}" == "SLES" ]]; then
        echo "0 0 * * * zypper patch --non-interactive" > ~/mycron
    elif [[ "${release}" == "Ubuntu" ]]; then
        apt-get install -y unattended-upgrades
        echo "0 0 * * * unattended-upgrades -d" > ~/mycron
    else
        echo "0 0 * * * yum -y update --security" > ~/mycron
    fi

    crontab ~/mycron
    rm ~/mycron

    echo "${FUNCNAME[0]} Ended"
}

##################################### End Function Definitions

# Call checkos to ensure platform is Linux
checkos

# Read the options from cli input
TEMP=`getopt -o h --longoptions help,admin-user: -n $0 -- "$@"`
eval set -- "${TEMP}"


if [[ $# == 1 ]] ; then echo "No input provided! type ($0 --help) to see usage help" >&2 ; exit 1 ; fi

# extract options and their arguments into variables.
while true; do
    case "$1" in
        -h | --help)
            usage
            exit 1
            ;;
        --admin-user)
            ADMIN_USER="$2";
            shift 2
            ;;
        --)
            break
            ;;
        *)
            break
            ;;
    esac
done

release=$(osrelease)
if [[ "${release}" == "Operating System Not Found" ]]; then
    echo "[ERROR] Unsupported Linux Bastion OS"
    exit 1
else
    setup_cron
fi

# ADMIN USER CONFIGURATION
ADMIN_PUB_KEY="/tmp/adminpubkey.pub"
if ! [ -z "$ADMIN_USER" ]; then
	if [[ -e ${ADMIN_PUB_KEY} ]]; then
		for SKEL in profile shrc; do
			if  [[ -e /tmp/${SKEL} ]]; then
				echo "[INFO] Moving /tmp/${SKEL} into place..."
				mv /tmp/$SKEL /etc/skel/.$SKEL
			else
				echo "[INFO] /tmp/$SKEL not found. "\
				 "Continuing..."
			fi
		done
		echo "[INFO] Adding admin user ... "
		useradd -G adm,wheel,systemd-journal -s /usr/bin/ksh $ADMIN_USER
		mv ${ADMIN_PUB_KEY} /home/ec2-user/.ssh/${ADMIN_USER}.pub
		cat /home/ec2-user/.ssh/${ADMIN_USER}.pub >> \
		    /home/ec2-user/.ssh/authorized_keys
		cp /home/ec2-user/.ssh/${ADMIN_USER}.pub /home/${ADMIN_USER}/
		chown ${ADMIN_USER}:${ADMIN_USER} \
		    /home/${ADMIN_USER}/${ADMIN_USER}.pub
		cd /home/${ADMIN_USER}
		mkdir .ssh
		chown ${ADMIN_USER}:${ADMIN_USER} .ssh
		mv ${ADMIN_USER}.pub .ssh/
		cat .ssh/${ADMIN_USER}.pub >> .ssh/authorized_keys
		chown ${ADMIN_USER}:${ADMIN_USER} .ssh/authorized_keys
		chmod 700 .ssh
		chmod 600 .ssh/authorized_keys
		cat <<EOF >>/etc/sudoers.d/cloud-init

# Added by bastion_bootstrap
# User rules for additional admin user
EOF
		echo "${ADMIN_USER} ALL=(ALL) NOPASSWD:ALL" \
		    >>/etc/sudoers.d/cloud-init
	else
		echo "[INFO] no public key found, skipping."
		exit 1;
	fi
fi

echo "Bootstrap complete."
