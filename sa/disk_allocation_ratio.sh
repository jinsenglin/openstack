#!/bin/bash

echo community default is 1.0

openstack hypervisor show -c free_disk_gb -c local_gb -c local_gb_used 1
openstack hypervisor show -c free_disk_gb -c local_gb -c local_gb_used 2
openstack hypervisor show -c free_disk_gb -c local_gb -c local_gb_used 3
