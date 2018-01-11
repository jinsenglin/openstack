#!/bin/bash

set -e

DEVSTACK_PIN_VERSION=9884f60ea44130b8f415924c7b7654bb17f83ab1   # or HEAD
DEVSTACK_LOCAL_CONF=/vagrant/local.conf.v2-keystone-only

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

function stopall() {
    cd devstack
    su stack -c './unstack.sh -a'
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
