#!/bin/bash

set -ex

if [ $# -lt 2 ]; then
	echo "Usage: $0 OPENRC_FILE STATE_DIR"
	exit 1
fi
OPENRC_FILE=$1
STATE_DIR=$2

source $OPENRC_FILE

# to cleanup servers
	source $STATE_DIR/create-floating-ips.state
	microbosh=$(nova list | grep $MICROBOSH_FLOATING_IP | awk '{print $2}')
#		nova delete $microbosh
		echo "deleted microbosh $microbosh"

	for server in $(nova list | grep ^\| | sed -n '2,$ p' | awk '{print $2}')
	do
#		nova delete $server
		echo "deleted server $server"
	done

# to cleanup volumes
	for volume in $(nova volume-list | grep ^\| | sed -n '2,$ p' | awk '{print $2}')
	do
#		nova volume-delete $volume
		echo "deleted volume $volume"
	done

# to cleanup image 
 	for image in $(glance image-list --owner $OS_TENANT_ID | grep ^\| | sed -n '2,$ p' | awk '{print $2}')
	do
#		glance image-delete $image
		echo "deleted image $image"
	done

# to cleanup router
	source $STATE_DIR/create-router-for-devops.state
#		neutron router-delete $ROUTER_ID
		echo "deleted router $ROUTER_ID"

# to cleanup network and subnet
	source $STATE_DIR/create-network-for-devops.state
#		neutron subnet-delete $SUBNET_ID
		echo "deleted subnet $SUBNET_ID"

#		neutron net-delete $NETWORK_ID
		echo "deleted network $NETWORK_ID"


# to cleanup ssh key pair
	for keypair in $(nova keypair-list | grep ^\| | sed -n '2,$ p' | awk '{print $2}')
	do
#		nova keypair-delete $keypair
		echo "deleted ssh key pair $keypair"
	done

# to cleanup security group and rules
	for secgrouprule in $(neutron security-group-rule-list | grep ^\| | sed -n '2,$ p' | awk '{print $2}')
	do
#		neutron security-group-rule-delete $secgrouprule
		echo "deleted security group rule $secgrouprule"
	done

	for secgroup in $(neutron security-group-list | grep ^\| | sed -n '2,$ p' | awk '{print $2}')
	do
#		neutron security-group-delete $secgroup
		echo "deleted security group $secgroup"
	done

# to cleanup floating ips
	for ip in $(neutron floatingip-list | grep ^\| | sed -n '2,$ p' | awk '{print $2}')
	do
#		neutron floatingip-delete $ip
		echo "deleted ip $ip"
	done

