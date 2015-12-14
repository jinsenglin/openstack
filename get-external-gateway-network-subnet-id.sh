#!/bin/bash -ex

source get-external-gateway-network.sh

export EXTERNAL_GW_NET_SUBNET_ID=$(echo $EXTERNAL_GW_NET | jq '.subnets[0]' | sed 's/"//g')
