#!/bin/bash

echo community default is 1.5

openstack hypervisor show -c memory_mb -c memory_mb_used 1
openstack hypervisor show -c memory_mb -c memory_mb_used 2
openstack hypervisor show -c memory_mb -c memory_mb_used 3
