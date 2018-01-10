#!/bin/bash

set -e

DEVSTACK_PIN_VERSION=9884f60ea44130b8f415924c7b7654bb17f83ab1 

function download() {
    apt-get update
    apt-get install -y git
    git clone https://github.com/openstack-dev/devstack.git -b stable/pike
}

function configure() {
    cd devstack
    git checkout $DEVSTACK_PIN_VERSION
    cp samples/local.conf .
    ./stack.sh
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
            *)
                echo "unknown mode"
                ;;
        esac
        shift
    done
    echo done
}
main $@
