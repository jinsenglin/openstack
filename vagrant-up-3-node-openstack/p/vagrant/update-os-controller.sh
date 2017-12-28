#!/bin/bash

set -e

function download_cinder() {
    apt-get install -y cinder-api cinder-scheduler
}

function configure_cinder() {
    :
}

function download_swift() {
    :
}

function configure_swift() {
    :
}

function main() {
    while [ $# -gt 0 ];
    do
        case $1 in
            download-cinder)
                download_cinder
                ;;
            configure-cinder)
                configure_cinder
                ;;
            plus-cinder)
                download_cinder
                configure_cinder
                ;;
            download-swift)
                download_swift
                ;;
            configure-swift)
                configure_swift
                ;;
            plus-swift)
                download_swift
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
