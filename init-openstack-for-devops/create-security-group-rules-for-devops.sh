#!/bin/bash

set -ex

SECURITY_GROUP_NAME=$1

# create security group
neutron security-group-create $SECURITY_GROUP_NAME

# create security group rules
neutron security-group-rule-create --protocol icmp --direction egress --remote_ip_prefix 0.0.0.0/0 --ethertype IPv4 $SECURITY_GROUP_NAME
neutron security-group-rule-create --protocol icmp --direction ingress --remote_ip_prefix 0.0.0.0/0 --ethertype IPv4 $SECURITY_GROUP_NAME
neutron security-group-rule-create --protocol tcp --direction ingress --port_range_min 1 --port_range_max 65535 --remote_ip_prefix 0.0.0.0/0 --ethertype IPv4 $SECURITY_GROUP_NAME
neutron security-group-rule-create --protocol tcp --direction egress --port_range_min 1 --port_range_max 65535 --remote_ip_prefix 0.0.0.0/0 --ethertype IPv4 $SECURITY_GROUP_NAME
neutron security-group-rule-create --protocol tcp --direction ingress --port_range_min 22 --port_range_max 22 --remote_ip_prefix 0.0.0.0/0 --ethertype IPv4 $SECURITY_GROUP_NAME
neutron security-group-rule-create --protocol tcp --direction ingress --port_range_min 53 --port_range_max 53 --remote_ip_prefix 0.0.0.0/0 --ethertype IPv4 $SECURITY_GROUP_NAME
neutron security-group-rule-create --protocol tcp --direction ingress --port_range_min 68 --port_range_max 68 --remote_ip_prefix 0.0.0.0/0 --ethertype IPv4 $SECURITY_GROUP_NAME
neutron security-group-rule-create --protocol tcp --direction ingress --port_range_min 80 --port_range_max 80 --remote_ip_prefix 0.0.0.0/0 --ethertype IPv4 $SECURITY_GROUP_NAME
neutron security-group-rule-create --protocol tcp --direction ingress --port_range_min 443 --port_range_max 443 --remote_ip_prefix 0.0.0.0/0 --ethertype IPv4 $SECURITY_GROUP_NAME
neutron security-group-rule-create --protocol tcp --direction ingress --port_range_min 2555 --port_range_max 2555 --remote_ip_prefix 0.0.0.0/0 --ethertype IPv4 $SECURITY_GROUP_NAME
neutron security-group-rule-create --protocol tcp --direction ingress --port_range_min 4222 --port_range_max 4222 --remote_ip_prefix 0.0.0.0/0 --ethertype IPv4 $SECURITY_GROUP_NAME
neutron security-group-rule-create --protocol tcp --direction ingress --port_range_min 4443 --port_range_max 4443 --remote_ip_prefix 0.0.0.0/0 --ethertype IPv4 $SECURITY_GROUP_NAME
neutron security-group-rule-create --protocol tcp --direction ingress --port_range_min 6868 --port_range_max 6868 --remote_ip_prefix 0.0.0.0/0 --ethertype IPv4 $SECURITY_GROUP_NAME
neutron security-group-rule-create --protocol udp --direction ingress --port_range_min 1 --port_range_max 65535 --remote_ip_prefix 0.0.0.0/0 --ethertype IPv4 $SECURITY_GROUP_NAME
neutron security-group-rule-create --protocol udp --direction egress --port_range_min 1 --port_range_max 65535 --remote_ip_prefix 0.0.0.0/0 --ethertype IPv4 $SECURITY_GROUP_NAME

