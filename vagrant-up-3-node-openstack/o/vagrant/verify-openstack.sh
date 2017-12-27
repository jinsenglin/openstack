#!/bin/bash

source /root/admin-openrc

#---------------------------------------------------#
#               Start checking                      #
# --------------------------------------------------#

openstack catalog list
openstack service list

# https://docs.openstack.org/ocata/install-guide-ubuntu/nova-verify.html
nova-status upgrade check
openstack hypervisor list
openstack compute service list
openstack server list

# https://docs.openstack.org/ocata/install-guide-ubuntu/neutron-verify.html
openstack extension list --network
openstack network agent list
openstack subnet pool list
openstack network list
openstack subnet list
openstack port list
openstack router list

openstack image list

openstack project list

#---------------------------------------------------#
#               Start creating resources            #
# --------------------------------------------------#

FLAT_NETWORK_NAME=external

# Create the provider network
PROVIDER_NETWORK_NAME=provider
openstack network create  --share --external --provider-physical-network $FLAT_NETWORK_NAME --provider-network-type flat $PROVIDER_NETWORK_NAME

# Create the provider subnet
openstack subnet create --network $PROVIDER_NETWORK_NAME --allocation-pool start=10.0.3.230,end=10.0.3.250 --dns-nameserver 8.8.8.8 --gateway 10.0.3.1 --subnet-range 10.0.3.0/24 --no-dhcp $PROVIDER_NETWORK_NAME

# Create a router
ROUTER_NAME=router
openstack router create $ROUTER_NAME
neutron router-gateway-set $ROUTER_NAME $PROVIDER_NETWORK_NAME

# Ping this router
ROUTER_IF_IP_PROVIDER=$( neutron router-port-list -c fixed_ips -f json $ROUTER_NAME | jq -r '.[0].fixed_ips' | jq -r '.[0].ip_address' )
ping -c 1 $ROUTER_IF_IP_PROVIDER

# Create a self-service network
SELFSERVICE_NETWORK_NAME=selfservice
openstack network create $SELFSERVICE_NETWORK_NAME

# Create the self-service subnet
openstack subnet create --network $SELFSERVICE_NETWORK_NAME --dns-nameserver 8.8.8.8 --gateway 10.10.10.1 --subnet-range 10.10.10.0/24 $SELFSERVICE_NETWORK_NAME
neutron router-interface-add $ROUTER_NAME $SELFSERVICE_NETWORK_NAME

# Ping this router again [ in network node ]
# QROUTER=$( ip netns | grep qrouter ) # e.g., qrouter-5f5b5e64-f08c-49ce-8a99-0eb955b4a4e0
# QDHCP=$( ip netns | grep qdhcp ) # e.g., qdhcp-e340195b-a086-44b6-965c-2613c23efe0a
# ip netns exec $QROUTER ping -c 1 10.10.10.1
# ip netns exec $QROUTER ping -c 1 $ROUTER_IF_IP_PROVIDER
# ip netns exec $QROUTER ping -c 1 10.0.3.1

# Create a flavor
openstack flavor create --id 0 --vcpus 1 --ram 64 --disk 1 m1.nano

# Permit ICMP (ping) in default security group
DEFAULT_SG_ID=$(openstack security group list --project admin -c ID -f value)
openstack security group rule create --proto icmp $DEFAULT_SG_ID

# Permit secure shell (SSH) access in default security group
openstack security group rule create --proto tcp --dst-port 22 $DEFAULT_SG_ID

# Launch an instance
SELFSERVICE_INSTANCE_NAME=selfservice-instance
openstack server create --flavor m1.nano --image cirros --nic net-id=$SELFSERVICE_NETWORK_NAME --security-group default $SELFSERVICE_INSTANCE_NAME
openstack server show $SELFSERVICE_INSTANCE_NAME # status ACTIVE

# Ping this instance [ in network node ]
# SELFSERVICE_INSTANCE_IF_IP=$( openstack server show -c addresses -f json $SELFSERVICE_INSTANCE_NAME | jq -r '.addresses' | awk -F = '{print $2}' )
# ip netns exec $QROUTER ping -c 1 $SELFSERVICE_INSTANCE_IF_IP

# Access this instance remotely
# nova get-vnc-console $SELFSERVICE_INSTANCE_NAME novnc

# Access this instance remotely
# Use VNC client to connect 10.0.0.31:5900

# Create a floating IP
openstack floating ip create $PROVIDER_NETWORK_NAME
SELFSERVICE_INSTANCE_FLOATING_IP=$( openstack floating ip list -c "Floating IP Address" -f json | jq -r '.[0]["Floating IP Address"]' )
openstack server add floating ip $SELFSERVICE_INSTANCE_NAME $SELFSERVICE_INSTANCE_FLOATING_IP

# Ping this instance again
ping -c 1 $SELFSERVICE_INSTANCE_FLOATING_IP

# Access this instance remotely
sshpass -p "cubswin:)" ssh -o StrictHostKeyChecking=no cirros@$SELFSERVICE_INSTANCE_FLOATING_IP hostname

# Ping gateway [ in instance ]
sshpass -p "cubswin:)" ssh -o StrictHostKeyChecking=no cirros@$SELFSERVICE_INSTANCE_FLOATING_IP ping -c 1 10.10.10.1
sshpass -p "cubswin:)" ssh -o StrictHostKeyChecking=no cirros@$SELFSERVICE_INSTANCE_FLOATING_IP ping -c 1 10.0.3.1

# Reference https://docs.openstack.org/newton/install-guide-ubuntu/launch-instance-networks-provider.html#launch-instance-networks-provider
# Reference https://docs.openstack.org/newton/install-guide-ubuntu/launch-instance-networks-selfservice.html
# Reference https://docs.openstack.org/newton/install-guide-ubuntu/launch-instance.html#launch-instance
# Reference https://docs.openstack.org/newton/install-guide-ubuntu/launch-instance-selfservice.html

# Create a loadbalancer
LB_NAME=test-lb
neutron lbaas-loadbalancer-create --name $LB_NAME $SELFSERVICE_NETWORK_NAME
neutron lbaas-loadbalancer-show $LB_NAME
neutron lbaas-loadbalancer-stats $LB_NAME

LB_EXT_NAME=test-lb-ext
neutron lbaas-loadbalancer-create --name $LB_EXT_NAME $PROVIDER_NETWORK_NAME
neutron lbaas-loadbalancer-show $LB_EXT_NAME
neutron lbaas-loadbalancer-stats $LB_EXT_NAME

# TODO: Update the security group to allow traffic to reach the new load balancer.

# TODO: Adding an HTTP listener

# TODO: Adding an HTTPS listener

# TODO: Associating a floating IP address

# Reference https://docs.openstack.org/ocata/networking-guide/config-lbaas.html
