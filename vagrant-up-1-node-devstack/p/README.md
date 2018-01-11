branch stable/pike commit 9884f60ea44130b8f415924c7b7654bb17f83ab1

admin-openrc

```
vagrant ssh
sudo su stack
source devstack/openrc admin

openstack service list
openstack project list
```

sample local.conf

* https://www.sebastien-han.fr/blog/2013/08/16/best-localrc-for-devstack/
* https://assafmuller.com/2015/04/06/multinode-dvr-devstack/

message queue options

* zeromq
* qpid
* rabbit

openstack system unit file see `/etc/systemd/system/multi-user.target.wants`, e.g.

* devstack@keystone.service
* devstack@q-svc.service
* devstack@q-agt.service
* devstack@q-dhcp.service
* devstack@q-l3.service
* devstack@q-meta.service

devstack logs

* stack.sh log see /opt/stack/logs
* openstack log see systemctl status OS-SYSTEMD-UNIT-FILE
