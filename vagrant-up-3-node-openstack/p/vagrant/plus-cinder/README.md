# Usage

```
vagrant ssh os-controller -c "sudo /vagrant/update-os-controller.sh download-cinder"
vagrant up --provision-with download os-block

vagrant ssh os-controller -c "sudo /vagrant/update-os-controller.sh configure-cinder"
vagrant ssh os-block -c "sudo /vagrant/update-os-controller.sh configure-cinder"
```


# Plus

Update os-controller

```
vagrant ssh os-controller -c "sudo /vagrant/update-os-controller.sh plus-cinder" 
```

Bootstrap os-block

```
vagrant up --provision-with bootstrap os-block
```
