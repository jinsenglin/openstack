# Plus

Update os-controller

```
vagrant ssh os-controller -c "sudo /vagrant/update-os-controller.sh plus-heat" 
```

Verify orchestration service

```
openstack orchestration service list
```

```
# REF https://docs.openstack.org/heat/pike/install/launch-instance.html
# - image name: cirros
# - keypair name: keypair
# - flavor name: m1.nano

NET_ID=$(openstack network list | awk '/ selfservice / { print $2 }')
openstack stack create -t /vagrant/plus-heat/sample.hot/demo-template.yml --parameter "NetID=$NET_ID" stack
openstack stack list # Stack Status CREATE_COMPLETE
openstack stack output show --all stack
openstack server list
openstack stack delete --yes stack
```
