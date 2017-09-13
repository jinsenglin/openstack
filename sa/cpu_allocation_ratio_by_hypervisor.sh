#!/bin/bash

echo community default is 16.0

function query() {
openstack hypervisor show -c vcpus -c vcpus_used -f json $HYPERVISOR 2>/dev/null | tee /tmp/out
echo
echo "scale=2; $(cat /tmp/out  | jq -r '.vcpus_used') / $(cat /tmp/out  | jq -r '.vcpus')" | bc
echo
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
