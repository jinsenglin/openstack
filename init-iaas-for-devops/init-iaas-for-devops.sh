#!/bin/bash

set -ex

source devops-openrc.sh

ROUTER_NAME=devops-dev
EXTERNAL_NET_ID=b8e79f28-ce66-40a7-ac31-fa189fa42535
 
# to create router
# source create-router-for-devops.sh $ROUTER_NAME $EXTERNAL_NET_ID

NETWORK_NAME=devops-dev

# to create network and subnet
# source create-network-for-devops.sh $NETWORK_NAME 

# to link router and subnet
# bash link-router-and-subnet.sh $ROUTER_ID $SUBNET_ID

KEYPAIR_NAME=devops-dev

# to create ssh key pair
# bash create-ssh-key-pair.sh

SECURITY_GROUP_NAME=devops-dev

# to create security group and rules
# bash create-security-group-rules-for-devops.sh $SECURITY_GROUP_NAME

CLOUD_IMAGE_ID=412beaba-bb81-4e41-9f0e-afaf0a3aa3ad

# to update integration test script
bash update-integration-test-script.sh
