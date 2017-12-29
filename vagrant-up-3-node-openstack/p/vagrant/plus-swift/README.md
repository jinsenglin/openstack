# Status

LookupError: No section 'object-server' (prefixed by 'app' or 'application' or 'composite' or 'composit' or 'pipeline' or 'filter-app') found in config /etc/swift/container-server.conf

# Usage

```
vagrant ssh os-controller -c "sudo /vagrant/update-os-controller.sh download-swift"
vagrant up --provision-with download os-object

vagrant ssh os-controller -c "sudo /vagrant/update-os-controller.sh configure-swift" # PART I
vagrant ssh os-object -c "sudo /vagrant/bootstrap-os-object.sh configure" # PART I

vagrant ssh os-controller -c "sudo /vagrant/update-os-controller.sh configure-swift" # PART II
vagrant ssh os-object -c "sudo /vagrant/bootstrap-os-object.sh configure" # PART II

vagrant ssh os-controller -c "sudo /vagrant/update-os-controller.sh configure-swift" # PART III
vagrant ssh os-object -c "sudo /vagrant/bootstrap-os-object.sh configure" # PART III
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
