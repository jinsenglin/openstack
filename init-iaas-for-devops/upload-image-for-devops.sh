#!/bin/bash

set -ex

INSTALLER_IMAGE_FILE=$1
UBUNTU_IMAGE_FILE=$2

# create installer image
	export INSTALLER_IMAGE_ID=$(glance image-create --is-public False --disk-format raw --container-format bare --name platform-installer | grep id | awk '{print $4}')
	echo "export INSTALLER_IMAGE_ID=$INSTALLER_IMAGE_ID" >> upload-image-for-devops.state

# upload installer image
	glance image-update --progress --file $INSTALLER_IMAGE_FILE $INSTALLER_IMAGE_ID

# create ubuntu image
	export UBUNTU_IMAGE_ID=$(glance image-create --is-public False --disk-format qcow2 --container-format bare --name trusty-server-cloudimg-amd64 | grep id | awk '{print $4}')
	echo "export UBUNTU_IMAGE_ID=$UBUNTU_IMAGE_ID" >> upload-image-for-devops.state

# upload ubuntu image
	glance image-update --progress --file $UBUNTU_IMAGE_FILE $UBUNTU_IMAGE_ID
