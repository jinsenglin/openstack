#!/bin/bash

set -e

function main() {
    while [ $# -gt 0 ];
    do
        case $1 in
            plus-cinder)
                ;;
            plus-swift)
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
