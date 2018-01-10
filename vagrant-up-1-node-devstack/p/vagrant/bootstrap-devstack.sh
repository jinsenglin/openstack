#!/bin/bash

set -e

function download() {
    apt-get update
    apt-get install -y git
    git clone https://github.com/openstack-dev/devstack.git -b stable/pike
}

function configure() {
    cd devstack
    cp samples/local.conf .
    ./stack.sh
}

function main() {
    while [ $# -gt 0 ];
    do
        case $1 in
            download)
                ;;
            configure)
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
