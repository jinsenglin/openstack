#!/bin/bash

set -e

DEVSTACK_PIN_VERSION=9884f60ea44130b8f415924c7b7654bb17f83ab1   # or HEAD
DEVSTACK_LOCAL_CONF=/vagrant/local.conf.v3-keystone-neutron

function download() {
    apt-get update
    apt-get install -y git
    git clone https://github.com/openstack-dev/devstack.git -b stable/pike

    # pre-configure
    cd devstack
    git checkout $DEVSTACK_PIN_VERSION
    HOST_IP=10.0.0.11 ./tools/create-stack-user.sh
    chown -R stack:stack .
}

function configure() {
    cd devstack
    cp $DEVSTACK_LOCAL_CONF ./local.conf
    su stack -c './stack.sh'
}

function restack() {
    cd devstack
    su stack -c './unstack.sh'
    su stack -c './stack.sh'
}

function unstackall() {
    cd devstack
    su stack -c './unstack.sh -a'

    # NOTE
    # before re-stacking
    # run `service mysql start`
    # run `service rabbitmq-server start`
}

function stopall() {
    su stack -c 'systemctl stop devstack@keystone.service'
    su stack -c 'systemctl stop devstack@q-svc.service'
    su stack -c 'systemctl stop devstack@q-agt.service'
    su stack -c 'systemctl stop devstack@q-dhcp.service'
    su stack -c 'systemctl stop devstack@q-l3.service'
    su stack -c 'systemctl stop devstack@q-meta.service'
}

function main() {
    while [ $# -gt 0 ];
    do
        case $1 in
            download)
                download
                ;;
            configure)
                configure
                ;;
            restack)
                restack
                ;;
            stopall)
                stopall
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
