#!/bin/bash -ex

source get-external-gateway-network.sh

export EXTERNAL_GW_NET_ID=$(echo $EXTERNAL_GW_NET | jq '.id' | sed 's/"//g')
