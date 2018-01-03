#!/bin/bash

function download_ironic() {
    :
}

function configure_ironic() {
    :
}

function main() {
    while [ $# -gt 0 ];
    do
        case $1 in
            download-ironic)
                download_ironic
                ;;
            configure-ironic)
                configure_ironic
                ;;
            plus-ironic)
                download_ironic
                configure_ironic
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
