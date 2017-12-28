# Usage

```
vagrant ssh os-controller -c "sudo /vagrant/update-os-controller.sh download-cinder"
vagrant up --provision-with download os-block

vagrant ssh os-controller -c "sudo /vagrant/update-os-controller.sh configure-cinder"
vagrant ssh os-block -c "sudo /vagrant/bootstrap-os-block.sh configure"
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

Verify block service

```
openstack volume service list

+------------------+---------------+------+---------+-------+----------------------------+
| Binary           | Host          | Zone | Status  | State | Updated At                 |
+------------------+---------------+------+---------+-------+----------------------------+
| cinder-scheduler | os-controller | nova | enabled | up    | 2017-12-28T06:11:07.000000 |
| cinder-volume    | os-block@lvm  | nova | enabled | up    | 2017-12-28T06:11:10.000000 |
+------------------+---------------+------+---------+-------+----------------------------+
```
