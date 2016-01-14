#!/bin/bash

set -ex

NETWORK_NAME=$1

# create network
	export NETWORK_ID=$(neutron net-create $NETWORK_NAME -f shell --variable id | tail -n 1 | awk 'BEGIN {FS="="}; {print $2}' | sed 's/"//g')
	echo "export NETWORK_ID=$NETWORK_ID" >> create-network-for-devops.state

# create subnet
	export SUBNET_ID=$(neutron subnet-create $NETWORK_ID 192.168.100.0/24 --name devops --dns-nameserver 8.8.8.8 -f shell --variable id | tail -n 1 | awk 'BEGIN {FS="="}; {print $2}' | sed 's/"//g')
	echo "export SUBNET_ID=$SUBNET_ID" >> create-network-for-devops.state
