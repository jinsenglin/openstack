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
    # [ PART I ]

    # Format the /dev/sdb and /dev/sdc devices as XFS
    mkfs.xfs /dev/sdb
    mkfs.xfs /dev/sdc

    # Create the mount point directory structure
    mkdir -p /srv/node/sdb
    mkdir -p /srv/node/sdc

    # Edit the /etc/fstab file
    echo "/dev/sdb /srv/node/sdb xfs noatime,nodiratime,nobarrier,logbufs=8 0 2" >> /etc/fstab
    echo "/dev/sdc /srv/node/sdc xfs noatime,nodiratime,nobarrier,logbufs=8 0 2" >> /etc/fstab

    # Mount the devices
    mount /srv/node/sdb
    mount /srv/node/sdc

    # Create or edit the /etc/rsyncd.conf file
    cat > /etc/rsyncd.conf <<DATA
uid = swift
gid = swift
log file = /var/log/rsyncd.log
pid file = /var/run/rsyncd.pid
address = $ENV_MGMT_OS_OBJECT_IP

[account]
max connections = 2
path = /srv/node/
read only = False
lock file = /var/lock/account.lock

[container]
max connections = 2
path = /srv/node/
read only = False
lock file = /var/lock/container.lock

[object]
max connections = 2
path = /srv/node/
read only = False
lock file = /var/lock/object.lock
DATA

    # Edit the /etc/default/rsync file and enable the rsync service
    sed -i 's/RSYNC_ENABLE=false/RSYNC_ENABLE=true/' /etc/default/rsync

    # Start the rsync service
    service rsync start

    # Download /etc/swift/account-server.conf
    cp /vagrant/sample.conf/account-server.conf /etc/swift/account-server.conf

    # Download /etc/swift/container-server.conf
    cp /vagrant/sample.conf/container-server.conf /etc/swift/container-server.conf

    # Download /etc/swift/object-server.conf
    cp /vagrant/sample.conf/object-server.conf /etc/swift/object-server.conf

    # Edit the /etc/swift/account-server.conf file, [DEFAULT] section
    crudini --set  /etc/swift/account-server.conf DEFAULT bind_ip "$ENV_MGMT_OS_OBJECT_IP"
    crudini --set  /etc/swift/account-server.conf DEFAULT bind_port "6202"
    crudini --set  /etc/swift/account-server.conf DEFAULT user "swift"
    crudini --set  /etc/swift/account-server.conf DEFAULT swift_dir "/etc/swift"
    crudini --set  /etc/swift/account-server.conf DEFAULT devices "/srv/node"
    crudini --set  /etc/swift/account-server.conf DEFAULT mount_check "True"

    # Edit the /etc/swift/account-server.conf file, [pipeline:main] section
    crudini --set  /etc/swift/account-server.conf pipeline:main pipeline "healthcheck recon account-server"

    # Edit the /etc/swift/account-server.conf file, [filter:recon] section
    crudini --set  /etc/swift/account-server.conf filter:recon use "egg:swift#recon"
    crudini --set  /etc/swift/account-server.conf filter:recon recon_cache_path "/var/cache/swift"

    # Edit the /etc/swift/container-server.conf file, [DEFAULT] section
    crudini --set  /etc/swift/container-server.conf DEFAULT bind_ip "$ENV_MGMT_OS_OBJECT_IP"
    crudini --set  /etc/swift/container-server.conf DEFAULT bind_port "6201"
    crudini --set  /etc/swift/container-server.conf DEFAULT user "swift"
    crudini --set  /etc/swift/container-server.conf DEFAULT swift_dir "/etc/swift"
    crudini --set  /etc/swift/container-server.conf DEFAULT devices "/srv/node"
    crudini --set  /etc/swift/container-server.conf DEFAULT mount_check "True"

    # Edit the /etc/swift/container-server.conf file, [pipeline:main] section
    crudini --set  /etc/swift/container-server.conf pipeline:main pipeline "healthcheck recon container-server"

    # Edit the /etc/swift/container-server.conf file, [filter:recon] section
    crudini --set  /etc/swift/container-server.conf filter:recon use "egg:swift#recon"
    crudini --set  /etc/swift/container-server.conf filter:recon recon_cache_path "/var/cache/swift"

    # Edit the /etc/swift/object-server.conf file, [DEFAULT] section
    crudini --set  /etc/swift/container-server.conf DEFAULT bind_ip "$ENV_MGMT_OS_OBJECT_IP"
    crudini --set  /etc/swift/container-server.conf DEFAULT bind_port "6200"
    crudini --set  /etc/swift/container-server.conf DEFAULT user "swift"
    crudini --set  /etc/swift/container-server.conf DEFAULT swift_dir "/etc/swift"
    crudini --set  /etc/swift/container-server.conf DEFAULT devices "/srv/node"
    crudini --set  /etc/swift/container-server.conf DEFAULT mount_check "True"

    # Edit the /etc/swift/object-server.conf file, [pipeline:main] section
    crudini --set  /etc/swift/container-server.conf pipeline:main pipeline "healthcheck recon object-server"

    # Edit the /etc/swift/object-server.conf file, [filter:recon] section
    crudini --set  /etc/swift/object-server.conf filter:recon use "egg:swift#recon"
    crudini --set  /etc/swift/object-server.conf filter:recon recon_cache_path "/var/cache/swift"
    crudini --set  /etc/swift/object-server.conf filter:recon recon_lock_path "/var/lock"

    # Ensure proper ownership of the mount point directory structure
    chown -R swift:swift /srv/node

    # Create the recon directory and ensure proper ownership of it
    mkdir -p /var/cache/swift
    chown -R root:swift /var/cache/swift
    chmod -R 775 /var/cache/swift

    # [ PART II ] - Copy the account.ring.gz, container.ring.gz, and object.ring.gz files to the /etc/swift directory on each storage node
    cp $CACHE/account.ring.gz /etc/swift/
    cp $CACHE/container.ring.gz /etc/swift/
    cp $CACHE/object.ring.gz /etc/swift/

    # [ PART III ] - Finalize installation

    # Copy the swift.conf file to the /etc/swift directory on each storage node
    cp $CACHE/swift.conf /etc/swift/

    # On all nodes, ensure proper ownership of the configuration directory
    chown -R root:swift /etc/swift

    # On the storage nodes, start the Object Storage services
    swift-init all start
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
