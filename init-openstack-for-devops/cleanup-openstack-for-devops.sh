#!/bin/bash

set -ex

if [ $# -lt 2 ]; then
	echo "Usage: $0 OPENRC_FILE STATE_DIR"
	exit 1
fi
OPENRC_FILE=$1
STATE_DIR=$2

source $OPENRC_FILE

function cleanup_microbosh() { 
	source $STATE_DIR/create-floating-ips.state
	microbosh=$(nova list | grep $MICROBOSH_FLOATING_IP | awk '{print $2}')
		nova delete $microbosh
		echo "deleted microbosh $microbosh"

	sleep 60
}

function cleanup_servers() { 
	for server in $(nova list | grep ^\| | sed -n '2,$ p' | awk '{print $2}')
	do
		nova delete $server
		echo "deleted server $server"
	done
}

function cleanup_volumes() {
	for volume in $(nova volume-list | grep ^\| | sed -n '2,$ p' | awk '{print $2}')
	do
		nova volume-delete $volume
		echo "deleted volume $volume"
	done
}

function cleanup_images () { 
 	for image in $(glance image-list --owner $OS_TENANT_ID | grep ^\| | sed -n '2,$ p' | awk '{print $2}')
	do
		glance image-delete $image
		echo "deleted image $image"
	done
}

function cleanup_security_groups_and_rules() {
	for secgrouprule in $(neutron security-group-rule-list | grep ^\| | sed -n '2,$ p' | awk '{print $2}')
	do
		neutron security-group-rule-delete $secgrouprule
		echo "deleted security group rule $secgrouprule"
	done

	for secgroup in $(neutron security-group-list | grep ^\| | sed -n '2,$ p' | awk '{print $2}')
	do
		neutron security-group-delete $secgroup
		echo "deleted security group $secgroup"
	done
}

function cleanup_ssh_key_pairs() {
	for keypair in $(nova keypair-list | grep ^\| | sed -n '2,$ p' | awk '{print $2}')
	do
		nova keypair-delete $keypair
		echo "deleted ssh key pair $keypair"
	done
}

function cleanup_floating_ips() {
	for ip in $(neutron floatingip-list | grep ^\| | sed -n '2,$ p' | awk '{print $2}')
	do
		neutron floatingip-delete $ip
		echo "deleted ip $ip"
	done
}

function cleanup_network_and_subnet_and_router() {
	source $STATE_DIR/create-router-for-devops.state
	source $STATE_DIR/create-network-for-devops.state
		neutron router-interface-delete $ROUTER_ID $SUBNET_ID
		echo "deleted interface of router $ROUTER_ID from subnet $SUBNET_ID"

		neutron subnet-delete $SUBNET_ID
		echo "deleted subnet $SUBNET_ID"

		neutron net-delete $NETWORK_ID
		echo "deleted network $NETWORK_ID"

		neutron router-delete $ROUTER_ID
		echo "deleted router $ROUTER_ID"
}

#main
cleanup_microbosh
cleanup_servers 
cleanup_volumes
cleanup_images  
cleanup_security_groups_and_rules
cleanup_ssh_key_pairs
cleanup_floating_ips	
cleanup_network_and_subnet_and_router
