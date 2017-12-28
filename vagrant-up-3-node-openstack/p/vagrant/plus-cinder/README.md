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

```
openstack limits show --absolute

+--------------------------+-------+
| Name                     | Value |
+--------------------------+-------+
| maxServerMeta            |   128 |
| maxTotalInstances        |    10 |
| maxPersonality           |     5 |
| totalServerGroupsUsed    |     0 |
| maxImageMeta             |   128 |
| maxPersonalitySize       | 10240 |
| maxTotalRAMSize          | 51200 |
| maxServerGroups          |    10 |
| maxSecurityGroupRules    |    20 |
| maxTotalKeypairs         |   100 |
| totalCoresUsed           |     0 |
| totalRAMUsed             |     0 |
| maxSecurityGroups        |    10 |
| totalFloatingIpsUsed     |     0 |
| totalInstancesUsed       |     0 |
| maxServerGroupMembers    |    10 |
| maxTotalFloatingIps      |    10 |
| totalSecurityGroupsUsed  |     0 |
| maxTotalCores            |    20 |
| totalSnapshotsUsed       |     0 |
| maxTotalBackups          |    10 |
| maxTotalVolumeGigabytes  |  1000 |
| maxTotalSnapshots        |    10 |
| maxTotalBackupGigabytes  |  1000 |
| totalBackupGigabytesUsed |     0 |
| maxTotalVolumes          |    10 |
| totalVolumesUsed         |     0 |
| totalBackupsUsed         |     0 |
| totalGigabytesUsed       |     0 |
+--------------------------+-------+
```

```
openstack volume create --size 1 1GB-HDD
openstack volume show 1GB-HDD # status available
openstack server add volume --device /dev/vdb $SELFSERVICE_INSTANCE_NAME 1GB-HDD
sshpass -p "cubswin:)" ssh -o StrictHostKeyChecking=no cirros@$SELFSERVICE_INSTANCE_FLOATING_IP ls -l /dev/vdb
```
