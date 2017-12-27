#!/bin/bash

set -e

# --------------------------------------------------------------------------------------------

echo "source admin-openrc"
source /root/admin-openrc

# --------------------------------------------------------------------------------------------

echo "nova-status upgrade check"
nova-status upgrade check

# ref https://docs.openstack.org/ocata/install-guide-ubuntu/nova-verify.html

<<output
+---------------------------+
| Upgrade Check Results     |
+---------------------------+
| Check: Cells v2           |
| Result: Success           |
| Details: None             |
+---------------------------+
| Check: Placement API      |
| Result: Success           |
| Details: None             |
+---------------------------+
| Check: Resource Providers |
| Result: Success           |
| Details: None             |
+---------------------------+
output

# --------------------------------------------------------------------------------------------

echo "openstack module list"
openstack module list

<<output
+-----------------+--------+
| Field           | Value  |
+-----------------+--------+
| cinderclient    | 3.1.0  |
| designateclient | 2.7.0  |
| keystoneclient  | 3.13.0 |
| novaclient      | 9.1.0  |
| openstack       | 0.9.17 |
| openstackclient | 3.12.0 |
| swiftclient     | 3.4.0  |
+-----------------+--------+
output

echo "openstack region list"
openstack region list

<<output
+-----------+---------------+-------------+
| Region    | Parent Region | Description |
+-----------+---------------+-------------+
| RegionOne | None          |             |
+-----------+---------------+-------------+
output

echo "openstack service list"
openstack service list

<<output
+----------------------------------+-----------+-----------+
| ID                               | Name      | Type      |
+----------------------------------+-----------+-----------+
| 01c927f8e80a422bbfd2563d138e00c9 | glance    | image     |
| 1d4a6ae60cb14d54bd456cd44eed7252 | nova      | compute   |
| 3b79affc849c4b85adde98799839b34c | neutron   | network   |
| 65cb4acab4ef41b58707850c4af5dfae | keystone  | identity  |
| 8cefe9ce67bf4546b752c2678f174fe7 | placement | placement |
+----------------------------------+-----------+-----------+
output

echo "openstack endpoint list"
openstack endpoint list

<<output
+----------------------------------+-----------+--------------+--------------+---------+-----------+----------------------------------------------+
| ID                               | Region    | Service Name | Service Type | Enabled | Interface | URL                                          |
+----------------------------------+-----------+--------------+--------------+---------+-----------+----------------------------------------------+
| 011eb3be406141a59de49b8d7a2d1b5a | RegionOne | nova         | compute      | True    | admin     | http://os-controller:8774/v2.1/%(tenant_id)s |
| 2758a63f7ae8472897e55d3d508b8962 | RegionOne | placement    | placement    | True    | internal  | http://os-controller:8778                    |
| 3ff699932da34e2582d04065d8fde86d | RegionOne | neutron      | network      | True    | public    | http://os-controller:9696                    |
| 63ee3c5867fc43328d25f7ecfe60d697 | RegionOne | keystone     | identity     | True    | public    | http://os-controller:5000/v3/                |
| 6ff8cea212464a7d99195dbaced98534 | RegionOne | neutron      | network      | True    | admin     | http://os-controller:9696                    |
| 746153fdc3d4491799220414de046e24 | RegionOne | keystone     | identity     | True    | internal  | http://os-controller:5000/v3/                |
| 74cd3597ceb44dedadaccd946af768da | RegionOne | glance       | image        | True    | admin     | http://os-controller:9292                    |
| 9baf67b11fde4e1a9adac29c81cbbbe4 | RegionOne | keystone     | identity     | True    | admin     | http://os-controller:35357/v3/               |
| b055932e7d554c5da9a9407aa8751007 | RegionOne | neutron      | network      | True    | internal  | http://os-controller:9696                    |
| bcbe8649562b4e6fb2017f66b73dd5da | RegionOne | placement    | placement    | True    | public    | http://os-controller:8778                    |
| c308e97894894fa397d3ea12a63f4638 | RegionOne | nova         | compute      | True    | internal  | http://os-controller:8774/v2.1/%(tenant_id)s |
| ce49286229254a8f9e1b6cc9f6bf9991 | RegionOne | glance       | image        | True    | internal  | http://os-controller:9292                    |
| da6d03043c01456292e89ee0d31139c2 | RegionOne | glance       | image        | True    | public    | http://os-controller:9292                    |
| e29d2515c0c44ea49968e9e8e3fb174d | RegionOne | nova         | compute      | True    | public    | http://os-controller:8774/v2.1/%(tenant_id)s |
| f16b3260100a4f968b323c3e652f5dc6 | RegionOne | placement    | placement    | True    | admin     | http://os-controller:8778                    |
+----------------------------------+-----------+--------------+--------------+---------+-----------+----------------------------------------------+
output

echo "openstack catalog list"
openstack catalog list

<<output
+-----------+-----------+-----------------------------------------------------------------------------+
| Name      | Type      | Endpoints                                                                   |
+-----------+-----------+-----------------------------------------------------------------------------+
| glance    | image     | RegionOne                                                                   |
|           |           |   admin: http://os-controller:9292                                          |
|           |           | RegionOne                                                                   |
|           |           |   internal: http://os-controller:9292                                       |
|           |           | RegionOne                                                                   |
|           |           |   public: http://os-controller:9292                                         |
|           |           |                                                                             |
| nova      | compute   | RegionOne                                                                   |
|           |           |   admin: http://os-controller:8774/v2.1/0e64d5f3b808499f94a936251439cd03    |
|           |           | RegionOne                                                                   |
|           |           |   internal: http://os-controller:8774/v2.1/0e64d5f3b808499f94a936251439cd03 |
|           |           | RegionOne                                                                   |
|           |           |   public: http://os-controller:8774/v2.1/0e64d5f3b808499f94a936251439cd03   |
|           |           |                                                                             |
| neutron   | network   | RegionOne                                                                   |
|           |           |   public: http://os-controller:9696                                         |
|           |           | RegionOne                                                                   |
|           |           |   admin: http://os-controller:9696                                          |
|           |           | RegionOne                                                                   |
|           |           |   internal: http://os-controller:9696                                       |
|           |           |                                                                             |
| keystone  | identity  | RegionOne                                                                   |
|           |           |   public: http://os-controller:5000/v3/                                     |
|           |           | RegionOne                                                                   |
|           |           |   internal: http://os-controller:5000/v3/                                   |
|           |           | RegionOne                                                                   |
|           |           |   admin: http://os-controller:35357/v3/                                     |
|           |           |                                                                             |
| placement | placement | RegionOne                                                                   |
|           |           |   internal: http://os-controller:8778                                       |
|           |           | RegionOne                                                                   |
|           |           |   public: http://os-controller:8778                                         |
|           |           | RegionOne                                                                   |
|           |           |   admin: http://os-controller:8778                                          |
|           |           |                                                                             |
+-----------+-----------+-----------------------------------------------------------------------------+
output

echo "openstack availability zone list"
openstack availability zone list

<<output
+-----------+-------------+
| Zone Name | Zone Status |
+-----------+-------------+
| internal  | available   |
| nova      | available   |
| nova      | available   |
| nova      | available   |
+-----------+-------------+
output

echo "openstack host list"
openstack host list

<<output
+---------------+-------------+----------+
| Host Name     | Service     | Zone     |
+---------------+-------------+----------+
| os-controller | conductor   | internal |
| os-controller | scheduler   | internal |
| os-controller | consoleauth | internal |
| os-compute    | compute     | nova     |
+---------------+-------------+----------+
output

echo "openstack hypervisor list"
openstack hypervisor list

<<output
+----+---------------------+-----------------+-----------+-------+
| ID | Hypervisor Hostname | Hypervisor Type | Host IP   | State |
+----+---------------------+-----------------+-----------+-------+
|  1 | os-compute          | QEMU            | 10.0.0.31 | up    |
+----+---------------------+-----------------+-----------+-------+
output

echo "openstack compute service list"
openstack compute service list

<<output
+----+------------------+---------------+----------+---------+-------+----------------------------+
| ID | Binary           | Host          | Zone     | Status  | State | Updated At                 |
+----+------------------+---------------+----------+---------+-------+----------------------------+
|  3 | nova-conductor   | os-controller | internal | enabled | up    | 2017-12-27T08:42:43.213965 |
|  4 | nova-scheduler   | os-controller | internal | enabled | up    | 2017-12-27T08:42:42.514304 |
|  5 | nova-consoleauth | os-controller | internal | enabled | up    | 2017-12-27T08:42:42.008214 |
|  6 | nova-compute     | os-compute    | nova     | enabled | up    | 2017-12-27T08:42:36.236375 |
+----+------------------+---------------+----------+---------+-------+----------------------------+
output

echo "openstack network agent list"
openstack network agent list

<<output
+--------------------------------------+--------------------+------------+-------------------+-------+-------+---------------------------+
| ID                                   | Agent Type         | Host       | Availability Zone | Alive | State | Binary                    |
+--------------------------------------+--------------------+------------+-------------------+-------+-------+---------------------------+
| 250df0cb-bc10-40a8-8f52-7ebad1dc3fd5 | L3 agent           | os-network | nova              | :-)   | UP    | neutron-l3-agent          |
| 4a5431c9-b42a-4a16-a849-a329f16d4c49 | Open vSwitch agent | os-network | None              | :-)   | UP    | neutron-openvswitch-agent |
| 7ad20298-fc88-4444-8418-c3254d676a1c | DHCP agent         | os-network | nova              | :-)   | UP    | neutron-dhcp-agent        |
| d149024c-2444-40d2-96f7-b7cf6ee3f882 | Open vSwitch agent | os-compute | None              | :-)   | UP    | neutron-openvswitch-agent |
| d47f173a-41af-48a1-9b21-7368f5c5a81b | Metadata agent     | os-network | None              | :-)   | UP    | neutron-metadata-agent    |
+--------------------------------------+--------------------+------------+-------------------+-------+-------+---------------------------+
output

echo "openstack network service provider list"
openstack network service provider list

<<output
+---------------+-------------+---------+
| Service Type  | Name        | Default |
+---------------+-------------+---------+
| L3_ROUTER_NAT | single_node | False   |
| L3_ROUTER_NAT | ha          | False   |
| L3_ROUTER_NAT | dvrha       | False   |
| L3_ROUTER_NAT | dvr         | False   |
+---------------+-------------+---------+
output


echo "openstack domain list"
openstack domain list

<<output
+---------+---------+---------+--------------------+
| ID      | Name    | Enabled | Description        |
+---------+---------+---------+--------------------+
| default | Default | True    | The default domain |
+---------+---------+---------+--------------------+
output

echo "openstack project list"
openstack project list

<<output
+----------------------------------+---------+
| ID                               | Name    |
+----------------------------------+---------+
| 0e64d5f3b808499f94a936251439cd03 | admin   |
| 7d3ed47c22aa4085b8ba5af1782aac4e | service |
| e6efac67cc30405c8defce6154b5f6c6 | demo    |
+----------------------------------+---------+
output

echo "openstack user list"
openstack user list

<<output
+----------------------------------+-----------+
| ID                               | Name      |
+----------------------------------+-----------+
| 202cd838b0154a32ab9ee28cfb88dc29 | admin     |
| 30bb9c3602f24f0fadf754f107f0813b | demo      |
| 35cac65f79834f85bbf18845d895db80 | neutron   |
| 4c31576bbe204a7ab63bf331bc03ae6c | placement |
| 82fce2bcc53549edbcf5517d256a00ac | nova      |
| db5c4ee9c82b4519ba0455891fb5b6a2 | glance    |
+----------------------------------+-----------+
output

echo "openstack role list"
openstack role list

<<output
+----------------------------------+----------+
| ID                               | Name     |
+----------------------------------+----------+
| 9fe2ff9ee4384b1894a90878d3e92bab | _member_ |
| b3bdd0f1f14942feb80a5596d61496ba | user     |
| b567ade1e39640d789d41ad43baec113 | admin    |
+----------------------------------+----------+
output

# --------------------------------------------------------------------------------------------

FLAT_NETWORK_NAME=external
PROVIDER_NETWORK_NAME=provider
ROUTER_NAME=router
ROUTER_IF_IP_PROVIDER=
SELFSERVICE_NETWORK_NAME=selfservice
DEMO_DEFAULT_SECURITY_GROUP_ID=
SELFSERVICE_INSTANCE_NAME=selfservice-instance
SELFSERVICE_INSTANCE_FLOATING_IP=
SELFSERVICE_INSTANCE_2_NAME=selfservice-instance-2
SELFSERVICE_INSTANCE_2_PRIVATE_IP=

# --------------------------------------------------------------------------------------------

echo "openstack network create :: flat provider network"
openstack network create  --share --external --provider-physical-network $FLAT_NETWORK_NAME --provider-network-type flat $PROVIDER_NETWORK_NAME

echo "openstack subnet create :: CIDR 10.0.3.0/24"
openstack subnet create --network $PROVIDER_NETWORK_NAME --allocation-pool start=10.0.3.230,end=10.0.3.250 --dns-nameserver 8.8.8.8 --gateway 10.0.3.1 --subnet-range 10.0.3.0/24 --no-dhcp $PROVIDER_NETWORK_NAME

# --------------------------------------------------------------------------------------------

echo "openstack flavor create"
openstack flavor create --id 0 --vcpus 1 --ram 64 --disk 1 m1.nano

# --------------------------------------------------------------------------------------------

echo "source demo-openrc"
source /root/demo-openrc

# --------------------------------------------------------------------------------------------

echo "openstack router create"
openstack router create $ROUTER_NAME

echo "openstack router set :: gateway to provider network"
openstack router set $ROUTER_NAME --external-gateway $PROVIDER_NETWORK_NAME

echo "openstack router show :: gateway provider network ip"
ROUTER_IF_IP_PROVIDER=$(openstack router show $ROUTER_NAME -c external_gateway_info -f json | jq -r '.external_gateway_info' | jq '.external_fixed_ips' | jq -r '.[0].ip_address')

echo "ping provider network ip"
ping -c 1 $ROUTER_IF_IP_PROVIDER

echo "openstack network create :: self-service network a.k.a. tenant network"
openstack network create $SELFSERVICE_NETWORK_NAME

echo "openstack subnet create :: CIDR 10.10.10.0/24"
openstack subnet create --network $SELFSERVICE_NETWORK_NAME --dns-nameserver 8.8.8.8 --gateway 10.10.10.1 --subnet-range 10.10.10.0/24 $SELFSERVICE_NETWORK_NAME

echo "openstack router add subnet"
openstack router add subnet $ROUTER_NAME $SELFSERVICE_NETWORK_NAME

# --------------------------------------------------------------------------------------------

echo "openstack security group list :: demo project default security group id"
DEMO_DEFAULT_SECURITY_GROUP_ID=$(openstack security group list -c ID -f value)

echo "openstack security group rule create :: allow icmp by default"
openstack security group rule create --proto icmp $DEMO_DEFAULT_SECURITY_GROUP_ID

echo "openstack security group rule create :: allow ssh by default"
openstack security group rule create --proto tcp --dst-port 22 $DEMO_DEFAULT_SECURITY_GROUP_ID

# --------------------------------------------------------------------------------------------

echo "openstack server create"
openstack server create --wait --flavor m1.nano --image cirros --nic net-id=$SELFSERVICE_NETWORK_NAME --security-group $DEMO_DEFAULT_SECURITY_GROUP_ID $SELFSERVICE_INSTANCE_NAME

echo "openstack server show"
openstack server show $SELFSERVICE_INSTANCE_NAME # status ACTIVE

echo "openstack floating ip create"
openstack floating ip create $PROVIDER_NETWORK_NAME

echo "openstack floating ip list :: self-service instance floating ip"
SELFSERVICE_INSTANCE_FLOATING_IP=$( openstack floating ip list -c "Floating IP Address" -f json | jq -r '.[0]["Floating IP Address"]' )

echo "openstack server add floating ip"
openstack server add floating ip $SELFSERVICE_INSTANCE_NAME $SELFSERVICE_INSTANCE_FLOATING_IP

echo "ping self-service instance floating ip"
ping -c 1 $SELFSERVICE_INSTANCE_FLOATING_IP

echo "ssh login self-service instance :: print hostname"
sshpass -p "cubswin:)" ssh -o StrictHostKeyChecking=no cirros@$SELFSERVICE_INSTANCE_FLOATING_IP hostname

echo "ping gateway 10.10.10.1 from self-service instance"
sshpass -p "cubswin:)" ssh -o StrictHostKeyChecking=no cirros@$SELFSERVICE_INSTANCE_FLOATING_IP ping -c 1 10.10.10.1

echo "ping gateway 10.0.3.1 from self-service instance"
sshpass -p "cubswin:)" ssh -o StrictHostKeyChecking=no cirros@$SELFSERVICE_INSTANCE_FLOATING_IP ping -c 1 10.0.3.1

# --------------------------------------------------------------------------------------------

echo "openstack server create :: vm2"
openstack server create --wait --flavor m1.nano --image cirros --nic net-id=$SELFSERVICE_NETWORK_NAME --security-group $DEMO_DEFAULT_SECURITY_GROUP_ID $SELFSERVICE_INSTANCE_2_NAME

echo "openstack server show :: vm2"
openstack server show $SELFSERVICE_INSTANCE_2_NAME # status ACTIVE

echo "openstack server show :: vm2 private ip"
SELFSERVICE_INSTANCE_2_PRIVATE_IP=$(openstack server show $SELFSERVICE_INSTANCE_2_NAME -c addresses -f value | awk -F '=' '{print $2}')

echo "ping vm2 from vm1"
sshpass -p "cubswin:)" ssh -o StrictHostKeyChecking=no cirros@$SELFSERVICE_INSTANCE_FLOATING_IP ping -c 1 $SELFSERVICE_INSTANCE_2_PRIVATE_IP

# --------------------------------------------------------------------------------------------

echo "source admin-openrc"
source /root/admin-openrc

# --------------------------------------------------------------------------------------------

echo "openstack usage list"
openstack usage list

<<output
Usage from 2017-11-29 to 2017-12-28: 
+---------+---------+--------------+-----------+---------------+
| Project | Servers | RAM MB-Hours | CPU Hours | Disk GB-Hours |
+---------+---------+--------------+-----------+---------------+
| demo    |       2 |         4.36 |      0.07 |          0.07 |
+---------+---------+--------------+-----------+---------------+
output

echo "openstack project purge --keep-project --project demo"
openstack project purge --keep-project --dry-run --project demo

<<output
Deleting image : 8e4e8f31-20dc-4459-8220-e341227b0972
output

echo "NOTE user 'demo', router 'router', network 'selfservice', subnet 'selfservice', security group belong to 'demo', server belong to 'demo' will not be purged."
echo "NOTE try this https://github.com/openstack/ospurge"
