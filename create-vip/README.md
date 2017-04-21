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
