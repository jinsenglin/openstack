#!/bin/bash

set -e

openstack server create --flavor m1.medium --image Tony_Ubuntu_16.04.2_Srv_Cloud_v1.3 --security-group open-all --key-name devops --nic net-id=infra ceph-adm
openstack server create --flavor m1.medium --image Tony_Ubuntu_16.04.2_Srv_Cloud_v1.3 --security-group open-all --key-name devops --nic net-id=infra ceph-node1
openstack server create --flavor m1.medium --image Tony_Ubuntu_16.04.2_Srv_Cloud_v1.3 --security-group open-all --key-name devops --nic net-id=infra ceph-node2
openstack server create --flavor m1.medium --image Tony_Ubuntu_16.04.2_Srv_Cloud_v1.3 --security-group open-all --key-name devops --nic net-id=infra ceph-node3
openstack server create --flavor m1.medium --image Tony_Ubuntu_16.04.2_Srv_Cloud_v1.3 --security-group open-all --key-name devops --nic net-id=infra ceph-client

openstack volume create --size 10 ceph-node1_OSD1
openstack volume create --size 10 ceph-node2_OSD1
openstack volume create --size 10 ceph-node3_OSD1

openstack server add volume ceph-node1 ceph-node1_OSD1
openstack server add volume ceph-node2 ceph-node2_OSD1
openstack server add volume ceph-node3 ceph-node3_OSD1

openstack server add floating ip ceph-adm 192.168.240.48

scp id_rsa root@192.168.240.48:~/.ssh
