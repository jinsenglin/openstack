# Usage

```
vagrant ssh os-controller -c "sudo /vagrant/update-os-controller.sh download-swift"
vagrant up --provision-with download os-object

vagrant ssh os-controller -c "sudo /vagrant/update-os-controller.sh configure-swift"
vagrant ssh os-object -c "sudo /vagrant/bootstrap-os-object.sh configure"
```

# Plus

Update os-controller

```
vagrant ssh os-controller -c "sudo /vagrant/update-os-controller.sh plus-swift" 
```

Bootstrap os-object

```
vagrant up --provision-with bootstrap os-object
```

Verify object service

```
swift stat

openstack container create container1

echo FILE > FILE
openstack object create container1 FILE

openstack object list container1

rm FILE
openstack object save container1 FILE
```
