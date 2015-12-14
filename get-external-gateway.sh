#!/bin/bash -ex

source get-networks.sh

export RESP_JSON_EXTERNAL_GW=$(echo $RESP_JSON_NETWORKS | jq '.networks[] | select(.["router:external"] == true)')
