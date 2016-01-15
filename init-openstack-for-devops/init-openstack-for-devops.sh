#!/bin/bash

set -ex

if [ $# -lt 4 ]; then
	echo "Usage: $0 EXTERNAL_NET_ID INSTALLER_IMAGE_FILE UBUNTU_IMAGE_FILE OPENRC_FILE"
	exit 1
fi
EXTERNAL_NET_ID=$1
INSTALLER_IMAGE_FILE=$2
UBUNTU_IMAGE_FILE=$3
OPENRC_FILE=$4

source $OPENRC_FILE

# to upload image
	source upload-image-for-devops.sh $INSTALLER_IMAGE_FILE $UBUNTU_IMAGE_FILE
	source upload-image-for-devops.state
 
# to create router
	ROUTER_NAME=$OS_TENANT_NAME
	source create-router-for-devops.sh $ROUTER_NAME $EXTERNAL_NET_ID
	source create-router-for-devops.state

# to create network and subnet
	NETWORK_NAME=$OS_TENANT_NAME
	source create-network-for-devops.sh $NETWORK_NAME 
	source create-network-for-devops.state

# to link router and subnet
	bash link-router-and-subnet.sh $ROUTER_ID $SUBNET_ID

# to create ssh key pair
	KEYPAIR_NAME=$OS_TENANT_NAME
	bash create-ssh-key-pair.sh $KEYPAIR_NAME

# to create security group and rules
	SECURITY_GROUP_NAME=$OS_TENANT_NAME
	bash create-security-group-rules-for-devops.sh $SECURITY_GROUP_NAME

# to launch platform-installer virtual machine
	source launch-platform-installer-vm.sh $INSTALLER_IMAGE_ID $SECURITY_GROUP_NAME $KEYPAIR_NAME $NETWORK_ID
	source launch-platform-installer-vm.state

# to create floating ips
	source create-floating-ips.sh
	source create-floating-ips.state

# to create init-openstack-for-devops.state 
	bash create-init-openstack-for-devops.state.sh 
