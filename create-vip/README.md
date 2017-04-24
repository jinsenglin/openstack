# Create a port with specified IP address

Example

```bash
openstack port create --network net1 --fixed-ip subnet=subnet1,ip-address=192.0.2.40 port1
```

In the previous command, `net1` is the network name, which is a positional argument. `--fixed-ip subnet=<subnet>,ip-address=192.0.2.40` is an option which specifies the port’s fixed IP address we wanted.

Reference:

* https://docs.openstack.org/user-guide/cli-create-and-manage-networks.html

Note: supported in openstack-cli v3.9.0. Check new version https://pypi.python.org/pypi/python-openstackclient

---

CRUD

```bash
# List
openstack port list

# Delete
openstack port delete $PORT

# Show
openstack port show $PORT
```

---

To trace HTTP API calls

```bash
NET=net1
SUBNET=subnet1
PORT=port1
IP=192.0.2.40

openstack --debug port create --network $NET --fixed-ip subnet=$SUBNET,ip-address=$IP $PORT
openstack --debug port show $PORT
openstack --debug port delete $PORT
```

---

References:

* https://blog.codecentric.de/en/2016/11/highly-available-vips-openstack-vms-vrrp/

```
neutron port-create --name vip-port demo-net
neutron port-create --name vm1-port --allowed-address-pair ip_address=192.168.0.14 demo-net
neutron port-create --name vm2-port --allowed-address-pair ip_address=192.168.0.14 demo-net
neutron security-group-rule-create --protocol 112 vrrp
neutron security-group-rule-create --protocol tcp --port-range-min 22 --port-range-max 22 vrrp
neutron security-group-rule-create --protocol icmp vrrp
neutron port-update --security-group vrrp vm1-port
neutron port-update --security-group vrrp vm2-port
neutron floatingip-create floating
neutron floatingip-create floating
neutron floatingip-create floating
neutron floatingip-associate 55009db5-3720-4880-943e-266690356748 ae020587-e870-4e38-b72a-6c8980bb92f6
neutron floatingip-associate 4377aa79-d2f4-4977-ad63-4d9f8a7f2a42 9ef8a695-0409-43db-9878-bf6b555dcfee
neutron floatingip-associate 73dea280-4edf-49cc-8432-c3f56d87d531 928c8761-b98b-4c2f-be41-e4ab5ee82eab
nova boot --flavor m1.small --image ec83428f-39e3-4675-a3c6-eff37238dbbe --key-name my_keypair --nic port-id=9ef8a695-0409-43db-9878-bf6b555dcfee vm1
nova boot --flavor m1.small --image ec83428f-39e3-4675-a3c6-eff37238dbbe --key-name my_keypair --nic port-id=928c8761-b98b-4c2f-be41-e4ab5ee82eab vm2
ssh ubuntu@10.98.208.218
sudo apt install -y keepalived
ip a

# /etc/keepalived/keepalived.conf
vrrp_instance VIP_1 {
    state MASTER
    interface ens3
    virtual_router_id 51
    priority 150
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass supersecretpassword
    }
    virtual_ipaddress {
        192.168.0.14
    }
}

sudo systemctl restart keepalived
ping 10.98.208.217
sudo service keepalived stop
```
