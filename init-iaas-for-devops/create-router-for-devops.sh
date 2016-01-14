#!/bin/bash

set -ex

ROUTER_NAME=$1
EXTERNAL_NET_ID=$2

# create router
	export ROUTER_ID=$(neutron router-create $ROUTER_NAME -f shell --variable id | tail -n 1 | awk 'BEGIN {FS="="}; {print $2}' | sed 's/"//g')
	echo "export ROUTER_ID=$ROUTER_ID" >> create-router-for-devops.state

# set gateway
	neutron router-gateway-set $ROUTER_ID $EXTERNAL_NET_ID
