#!/bin/bash -ex

source get-networks.sh

export EXTERNAL_GW_NET=$(echo $RESP_JSON_NETWORKS | jq '.networks[] | select(.["router:external"] == true)')
