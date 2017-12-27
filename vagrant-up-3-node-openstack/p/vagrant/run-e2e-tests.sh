#!/bin/bash

set -e

# --------------------------------------------------------------------------------------------

source /root/admin-openrc

# --------------------------------------------------------------------------------------------

echo "openstack module list"
openstack module list

echo "openstack region list"
openstack region list

echo "openstack service list"
openstack service list

echo "openstack endpoint list"
openstack endpoint list

echo "openstack host list"
openstack host list

echo "openstack domain list"
openstack domain list

echo "openstack project list"
openstack project list

echo "openstack user list"
openstack user list

echo "openstack role list"
openstack role list

# --------------------------------------------------------------------------------------------

FLAT_NETWORK_NAME=external
PROVIDER_NETWORK_NAME=provider
ROUTER_NAME=router
ROUTER_IF_IP_PROVIDER=
SELFSERVICE_NETWORK_NAME=selfservice

# --------------------------------------------------------------------------------------------

echo "openstack network create :: flat provider network"
openstack network create  --share --external --provider-physical-network $FLAT_NETWORK_NAME --provider-network-type flat $PROVIDER_NETWORK_NAME

echo "openstack subnet create :: CIDR 10.0.3.0/24"
openstack subnet create --network $PROVIDER_NETWORK_NAME --allocation-pool start=10.0.3.230,end=10.0.3.250 --dns-nameserver 8.8.8.8 --gateway 10.0.3.1 --subnet-range 10.0.3.0/24 --no-dhcp $PROVIDER_NETWORK_NAME

echo "openstack router create"
openstack router create $ROUTER_NAME

echo "openstack router set :: gateway to provider network"
openstack router set $ROUTER_NAME --external-gateway $PROVIDER_NETWORK_NAME

echo "openstack router show :: gateway provider network ip"
ROUTER_IF_IP_PROVIDER=$(openstack router show $ROUTER_NAME -c external_gateway_info -f json | jq -r '.external_gateway_info' | jq '.external_fixed_ips' | jq -r '.[0].ip_address')

echo "ping provider network ip"
ping -c 1 $ROUTER_IF_IP_PROVIDER

# --------------------------------------------------------------------------------------------

echo "openstack network create :: self-service network a.k.a. tenant network"
openstack network create $SELFSERVICE_NETWORK_NAME

echo "openstack subnet create :: CIDR 10.10.10.0/24"
openstack subnet create --network $SELFSERVICE_NETWORK_NAME --dns-nameserver 8.8.8.8 --gateway 10.10.10.1 --subnet-range 10.10.10.0/24 $SELFSERVICE_NETWORK_NAME

