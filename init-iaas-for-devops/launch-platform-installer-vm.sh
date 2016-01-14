#!/bin/bash

set -ex

INSTALLER_IMAGE_ID=$1
SECURITY_GROUP_NAME=$2
KEYPAIR_NAME=$3
NETWORK_ID=$4

# create floating ip
	export INSTALLER_FLOATING_IP=$(nova floating-ip-create | sed -n '4 p' | awk '{print $2}')
	echo "export INSTALLER_FLOATING_IP=$INSTALLER_FLOATING_IP" >> launch-platform-installer-vm.state

# launch virtual machine
	INSTALLER_VM_ID=$(nova boot --flavor 2 --image $INSTALLER_IMAGE_ID --security-groups $SECURITY_GROUP_NAME --key-name $KEYPAIR_NAME --nic net-id=$NETWORK_ID platform-installer | grep id | head -n 1 | awk '{print $4}')

# wait for a while
	sleep 10

# associate floating ip to launch virtual machine
	nova floating-ip-associate $INSTALLER_VM_ID $INSTALLER_FLOATING_IP
