# devstack version

branch stable/pike commit 9884f60ea44130b8f415924c7b7654bb17f83ab1

# openrc file

admin-openrc

```
vagrant ssh
sudo su stack
source devstack/openrc admin

openstack service list
openstack project list
```

# local.conf file

sample local.conf

* https://www.sebastien-han.fr/blog/2013/08/16/best-localrc-for-devstack/
* https://assafmuller.com/2015/04/06/multinode-dvr-devstack/

# local.conf option

message queue options

* zeromq
* qpid
* rabbit

# no more screen

openstack system unit file see `/etc/systemd/system/multi-user.target.wants`, e.g.

* devstack@keystone.service
* devstack@q-svc.service
* devstack@q-agt.service
* devstack@q-dhcp.service
* devstack@q-l3.service
* devstack@q-meta.service

# log file

devstack logs

* stack.sh log see /opt/stack/logs
* openstack log see systemctl status OS-SYSTEMD-UNIT-FILE

# issue

when using zeromq, stack.sh hangs at here:

```
2018-01-11 07:57:54.121 | +lib/neutron_plugins/services/l3:_neutron_configure_router_v6:376  openstack --os-cloud devstack-admin --os-region RegionOne router add subnet 86980c2a-9a67-4af6-a875-382715d0b635 0e64347a-9148-46f3-8b9b-66e139428c8f
```

can not use `vagrant ssh` after reboot

```
# workaround
ssh -i .vagrant/machines/devstack/virtualbox/private_key vagrant@10.0.0.11
```

# hacking

file: /usr/local/lib/python2.7/dist-packages/keystone.egg-link

```
/opt/stack/keystone
```

file: /usr/local/lib/python2.7/dist-packages/neutron.egg-link

```
/opt/stack/neutron
```

folder: /usr/local/lib/python2.7/dist-packages/neutron_lib
