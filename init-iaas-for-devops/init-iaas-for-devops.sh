#!/bin/bash

set -ex

if [ $# -lt 2 ]; then
	echo "Usage: $0 EXTERNAL_NET_ID CLOUD_IMAGE_ID"
	exit 1
fi
POSTFIX="-dev" #empty for production; "-dev" for development

source devops-openrc.sh

 
# to create router
	ROUTER_NAME=devops$POSTFIX
	EXTERNAL_NET_ID=$1 
	# source create-router-for-devops.sh $ROUTER_NAME $EXTERNAL_NET_ID


# to create network and subnet
	NETWORK_NAME=devops$POSTFIX
	# source create-network-for-devops.sh $NETWORK_NAME 

# to link router and subnet
	# bash link-router-and-subnet.sh $ROUTER_ID $SUBNET_ID


# to create ssh key pair
	KEYPAIR_NAME=devops$POSTFIX
	# bash create-ssh-key-pair.sh

# to create security group and rules
	SECURITY_GROUP_NAME=devops$POSTFIX
	# bash create-security-group-rules-for-devops.sh $SECURITY_GROUP_NAME

# to update init-paas-for-devops.sh script
	CLOUD_IMAGE_ID=$2
	bash update-init-paas-for-devops.sh
