#!/bin/bash

set -e

ENV_MGMT_NETWORK="10.0.0.0/24"
ENV_MGMT_OS_CONTROLLER_IP="10.0.0.11"
ENV_MGMT_OS_NETWORK_IP="10.0.0.21"
ENV_MGMT_OS_COMPUTE_IP="10.0.0.31"
ENV_MGMT_OS_OBJECT_IP="10.0.0.61"

ENV_TUNNEL_NETWORK="10.0.1.0/24"
ENV_TUNNEL_OS_CONTROLLER_IP="10.0.1.11"
ENV_TUNNEL_OS_NETWORK_IP="10.0.1.21"
ENV_TUNNEL_OS_COMPUTE_IP="10.0.1.31"

LOG=/tmp/provision.log
date | tee $LOG            # when:  Thu Aug 10 07:48:13 UTC 2017
whoami | tee -a $LOG       # who:   root
pwd | tee -a $LOG          # where: /home/vagrant

CACHE=/vagrant/cache
[ -d $CACHE ] || mkdir -p $CACHE 

ARCHIVE=/vagrant/archive
[ -d $ARCHIVE ] || mkdir -p $ARCHIVE

function use_public_apt_server() {
    apt install -y software-properties-common
    add-apt-repository cloud-archive:pike
    apt-get update && APT_UPDATED=true

    # Reference https://docs.openstack.org/newton/install-guide-ubuntu/environment-packages.html
}

function use_local_apt_server() {
    cat > /etc/apt/sources.list <<DATA
deb http://192.168.240.3/ubuntu xenial main restricted
deb http://192.168.240.3/ubuntu xenial universe
deb http://192.168.240.3/ubuntu xenial multiverse
deb http://192.168.240.3/ubuntu xenial-updates main restricted
deb http://192.168.240.3/ubuntu xenial-updates universe
deb http://192.168.240.3/ubuntu xenial-updates multiverse
deb http://192.168.240.3/ubuntu xenial-security main restricted
deb http://192.168.240.3/ubuntu xenial-security universe
deb http://192.168.240.3/ubuntu xenial-security multiverse
deb http://192.168.240.3/ubuntu-cloud-archive xenial-updates/pike main
DATA

    rm -rf /var/lib/apt/lists/*
    echo 'APT::Get::AllowUnauthenticated "true";' > /etc/apt/apt.conf.d/99-use-local-apt-server
    apt-get update && APT_UPDATED=true
}

function each_node_must_resolve_the_other_nodes_by_name_in_addition_to_IP_address() {
    cat >> /etc/hosts <<DATA
$ENV_MGMT_OS_CONTROLLER_IP os-controller
$ENV_MGMT_OS_NETWORK_IP os-network
$ENV_MGMT_OS_COMPUTE_IP os-compute
DATA

    # Reference https://docs.openstack.org/newton/install-guide-ubuntu/environment-networking.html
}

function install_utilities() {
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    apt-get install -y crudini
}

function install_python() {
    PYTHON_VERSION=2.7.11-1
    PYTHON_PIP_VERSION=8.1.1-2ubuntu0.4
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    #apt-get install -y python=$PYTHON_VERSION python-pip=$PYTHON_PIP_VERSION
    apt-get install -y python python-pip
}

function install_ntp() {
    CHRONY_VERSION=2.1.1-1
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    #apt-get install -y chrony=$CHRONY_VERSION
    apt-get install -y chrony

    # # # # # # # # # # # # # # # # ## # # # # # # # # # # # # # # # # # # # # # # # # ## # # # # # # # #

    # To connect to the os-controller node
    sed -i "s/^pool /#pool /g" /etc/chrony/chrony.conf
    sed -i "s/^server /#server /g" /etc/chrony/chrony.conf
    echo "server os-controller iburst" >> /etc/chrony/chrony.conf

    # Restart the NTP service
    service chrony restart

    # Verify operation
    chronyc sources

    # Log files
    # /var/log/chrony/measurements.log
    # /var/log/chrony/statistics.log
    # /var/log/chrony/tracking.log

    # Reference https://docs.openstack.org/newton/install-guide-ubuntu/environment-ntp-other.html
}

function install_xfs() {
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    apt-get install -y xfsprogs
}

function install_rsync() {
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    apt-get install -y rsync
}

function download_swift() {
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    apt-get install -y swift swift-account swift-container swift-object
}

function configure_swift() {
    # Format the /dev/sdb and /dev/sdc devices as XFS
    mkfs.xfs /dev/sdb
    mkfs.xfs /dev/sdc

    # Create the mount point directory structure
    mkdir -p /srv/node/sdb
    mkdir -p /srv/node/sdc

    # Edit the /etc/fstab file TODO

    # Mount the devices
    mount /srv/node/sdb
    mount /srv/node/sdc

    # Create or edit the /etc/rsyncd.conf file TODO

    # Edit the /etc/default/rsync file and enable the rsync service TODO

    # Start the rsync service
    service rsync start

    # Download /etc/swift/account-server.conf TODO

    # Download /etc/swift/container-server.conf TODO

    # Download /etc/swift/object-server.conf TODO

    # Edit the /etc/swift/account-server.conf file, [DEFAULT] section TODO
    # Edit the /etc/swift/account-server.conf file, [pipeline:main] section TODO
    # Edit the /etc/swift/account-server.conf file, [filter:recon] section TODO

    # Edit the /etc/swift/container-server.conf file, [DEFAULT] section TODO
    # Edit the /etc/swift/container-server.conf file, [pipeline:main] section TODO
    # Edit the /etc/swift/container-server.conf file, [filter:recon] section TODO

    # Edit the /etc/swift/object-server.conf file, [DEFAULT] section TODO
    # Edit the /etc/swift/object-server.conf file, [pipeline:main] section TODO
    # Edit the /etc/swift/object-server.conf file, [filter:recon] section TODO

    # Ensure proper ownership of the mount point directory structure
    chown -R swift:swift /srv/node

    # Create the recon directory and ensure proper ownership of it
    mkdir -p /var/cache/swift
    chown -R root:swift /var/cache/swift
    chmod -R 775 /var/cache/swift
}

function main() {
    while [ $# -gt 0 ];
    do
        case $1 in
            download)
                #use_local_apt_server
                use_public_apt_server
                each_node_must_resolve_the_other_nodes_by_name_in_addition_to_IP_address
                install_utilities
                install_python
                install_ntp
                install_xfs
                install_rsync
                download_swift
                ;;
            configure)
                configure_swift
                ;;
            *)
                echo "unknown mode"
                ;;
        esac
        shift
    done
    echo done
}
main $@
