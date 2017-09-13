#!/bin/bash

echo community default is 1.0

function query() {
openstack hypervisor show -c free_disk_gb -c local_gb -c local_gb_used $HYPERVISOR 2>/dev/null
}

echo 1
HYPERVISOR=1
query

echo 2
HYPERVISOR=2
query

echo 3
HYPERVISOR=3
query
