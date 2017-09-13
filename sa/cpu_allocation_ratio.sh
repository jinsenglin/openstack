#!/bin/bash

echo community default is 16.0

openstack hypervisor show -c vcpus -c vcpus_used 1
openstack hypervisor show -c vcpus -c vcpus_used 2
openstack hypervisor show -c vcpus -c vcpus_used 3
