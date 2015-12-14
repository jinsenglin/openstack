#!/bin/bash -ex

source get-neutron-network-service.sh

export NEUTRON_NETWORK_SERV_PUBLIC_URL=$(echo $JSON_NEUTRON_NETWORK_SERV | jq '.endpoints[0].publicURL' | sed 's/"//g')
