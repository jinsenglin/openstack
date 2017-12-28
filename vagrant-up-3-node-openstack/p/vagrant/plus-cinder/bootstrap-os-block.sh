#!/bin/bash

set -e

ENV_MGMT_NETWORK="10.0.0.0/24"
ENV_MGMT_OS_CONTROLLER_IP="10.0.0.11"
ENV_MGMT_OS_NETWORK_IP="10.0.0.21"
ENV_MGMT_OS_COMPUTE_IP="10.0.0.31"
ENV_MGMT_OS_BLOCK_IP="10.0.0.51"

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

function install_lvm() {
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    apt-get install -y lvm2 thin-provisioning-tools
}

function download_cinder() {
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
    apt-get install -y cinder-volume
}

function configure_cinder() {
    # Create the LVM physical volume /dev/sdb
    pvcreate /dev/sdb

    # Create the LVM volume group cinder-volumes
    vgcreate cinder-volumes /dev/sdb

    # Edit the /etc/lvm/lvm.conf file
    sed -i '/^devices {$/ a filter = [ "a/sdb/", "r/.*/"]' /etc/lvm/lvm.conf

    # Edit the /etc/cinder/cinder.conf file, [database] section
    crudini --set /etc/cinder/cinder.conf database connection "mysql+pymysql://cinder:CINDER_DBPASS@os-controller/cinder"
    
    # Edit the /etc/cinder/cinder.conf file, [DEFAULT] section
    crudini --set /etc/cinder/cinder.conf DEFAULT transport_url "rabbit://openstack:RABBIT_PASS@os-controller"
    crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy "keystone"
    crudini --set /etc/cinder/cinder.conf DEFAULT my_ip "$ENV_MGMT_OS_BLOCK_IP"
    crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends "lvm"
    crudini --set /etc/cinder/cinder.conf DEFAULT glance_api_servers "http://os-controller:9292"

    # Edit the /etc/cinder/cinder.conf file, [keystone_authtoken] section
    crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_uri "http://os-controller:5000"
    crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url "http://os-controller:35357"
    crudini --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers "os-controller:11211"
    crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_type "password"
    crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name "default"
    crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name "default"
    crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name "service"
    crudini --set /etc/cinder/cinder.conf keystone_authtoken username "cinder"
    crudini --set /etc/cinder/cinder.conf keystone_authtoken password "CINDER_PASS"

    # Edit the /etc/cinder/cinder.conf file, [lvm] section
    crudini --set /etc/cinder/cinder.conf lvm volume_driver "cinder.volume.drivers.lvm.LVMVolumeDriver"
    crudini --set /etc/cinder/cinder.conf lvm volume_group "cinder-volumes"
    crudini --set /etc/cinder/cinder.conf lvm iscsi_protocol "iscsi"
    crudini --set /etc/cinder/cinder.conf lvm iscsi_helper "tgtadm"

    # Edit the /etc/cinder/cinder.conf file, [oslo_concurrency] section
    crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path "/var/lib/cinder/tmp"

    # Restart the Block Storage volume service including its dependencies
    service tgt restart
    service cinder-volume restart
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
                install_lvm
                download_cinder
                ;;
            configure)
                configure_cinder
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
