# Usage

```
vagrant ssh os-controller -c "sudo /vagrant/update-os-controller.sh download-swift"
vagrant up --provision-with download os-object

vagrant ssh os-controller -c "sudo /vagrant/update-os-controller.sh configure-swift-part1"
vagrant ssh os-object -c "sudo /vagrant/bootstrap-os-object.sh configure-part2"

vagrant ssh os-controller -c "sudo /vagrant/update-os-controller.sh configure-swift-part3"
vagrant ssh os-object -c "sudo /vagrant/bootstrap-os-object.sh configure-part4"

vagrant ssh os-controller -c "sudo /vagrant/update-os-controller.sh configure-swift-part5"
vagrant ssh os-object -c "sudo /vagrant/bootstrap-os-object.sh configure-part6"
```

# Plus

Update os-controller

```
vagrant ssh os-controller -c "sudo /vagrant/update-os-controller.sh download-swift"
vagrant ssh os-controller -c "sudo /vagrant/update-os-controller.sh configure-swift-part1"
```

Bootstrap os-object

```
vagrant up --provision-with download os-object
vagrant ssh os-object -c "sudo /vagrant/bootstrap-os-object.sh configure-part2"
```

Update os-controller

```
vagrant ssh os-controller -c "sudo /vagrant/update-os-controller.sh configure-swift-part3"
```

Update os-object

```
vagrant ssh os-object -c "sudo /vagrant/bootstrap-os-object.sh configure-part4"
```

Update os-controller

```
vagrant ssh os-controller -c "sudo /vagrant/update-os-controller.sh configure-swift-part5"
```

Update os-object

```
vagrant ssh os-object -c "sudo /vagrant/bootstrap-os-object.sh configure-part6"
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
