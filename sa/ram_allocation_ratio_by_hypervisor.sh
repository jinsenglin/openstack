#!/bin/bash

echo community default is 1.5

function query() {
openstack hypervisor show -c memory_mb -c memory_mb_used -f json $HYPERVISOR 2>/dev/null | tee /tmp/out
echo
echo "scale=2; $(cat /tmp/out  | jq -r '.memory_mb_used') / $(cat /tmp/out  | jq -r '.memory_mb')" | bc
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
