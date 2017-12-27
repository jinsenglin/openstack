#!/bin/bash

set -e

ENV_MGMT_NETWORK="10.0.0.0/24"
ENV_MGMT_OS_CONTROLLER_IP="10.0.0.11"
ENV_MGMT_OS_NETWORK_IP="10.0.0.21"
ENV_MGMT_OS_COMPUTE_IP="10.0.0.31"

ENV_TUNNEL_NETWORK="10.0.1.0/24"
ENV_TUNNEL_OS_CONTROLLER_IP="10.0.1.11"
ENV_TUNNEL_OS_NETWORK_IP="10.0.1.21"
ENV_TUNNEL_OS_COMPUTE_IP="10.0.1.31"

ENV_PUBLIC_INTERFACE="enp0s10"

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

function install() {
    [ "$APT_UPDATED" == "true" ] || apt-get update && APT_UPDATED=true
}

function configure() {
    # Enable Linux IP forwarding
    sysctl -w net.ipv4.ip_forward=1

    # Set up SNAT by iptables
    iptables -t nat -A POSTROUTING ! -d 10.0.3.0/24 -o enp0s3 -j SNAT --to-source 10.0.2.15

    # Reference https://www.systutorials.com/1372/setting-up-gateway-using-iptables-and-route-on-linux/
}

function main() {
    while [ $# -gt 0 ];
    do
        case $1 in
            download)
                #use_local_apt_server
                use_public_apt_server
                each_node_must_resolve_the_other_nodes_by_name_in_addition_to_IP_address
                install
                ;;
            configure)
                configure
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
