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
?
```
