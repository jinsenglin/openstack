# Goal

3-Node OpenStack Deployment

---

# Usage

```
vagrant up --provision-with download os-controller
vagrant up --provision-with download os-network
vagrant up --provision-with download os-compute

vagrant ssh os-controller -c "sudo /vagrant/bootstrap-os-controller.sh configure"
vagrant ssh os-network -c "sudo /vagrant/bootstrap-os-network.sh configure"
vagrant ssh os-compute -c "sudo /vagrant/bootstrap-os-compute.sh configure"

vagrant ssh os-controller -c "sudo /vagrant/run-e2e-tests.sh"
```

---

# Note on OpenStack

OpenStack version used is this deployment is pike.

* type_drivers: flat,vlan,vxlan
* provider network type: flat
* tenant_network_types: vxlan
* mechanism_drivers: openvswitch,l2population

---

# Note on VirtualBox

Each VirtualBox VM created by Vagrant has a NIC named "enp0s3" by default, which means that the first network interface (eth0 or enp0s3) is always managed by Vagrant and must be connected to a NAT network.

* VirtualBox network adapter :: Attached to: NAT
* VirtualBox network adapter :: Promiscuous mode: DENY
* IP: 10.0.2.15
* GW: 10.0.2.2
* MASK: 255.255.255.0

In this deployment, we add 4 NICs:

* VirtualBox network adapter :: Attached to: HOST-ONLY
* VirtualBox network adapter :: Promiscuous mode: ALLOW-ALL
* C class network
  * 10.0.0.0/24 for management network, enp0s8
  * 10.0.1.0/24 for tunnel network, enp0s9
  * 10.0.3.0/24 for public network, enp0s10
  * 10.0.4.0/24 preserved, not yet used, enp0s16

---

# Usage - Quickstart

```
vagrant up --provision-with bootstrap os-controller
vagrant up --provision-with bootstrap os-network
vagrant up --provision-with bootstrap os-compute

```

# Usage - Snapshot

```
vagrant up --provision-with download os-controller
vagrant up --provision-with download os-network
vagrant up --provision-with download os-compute
vagrant snapshot save ready-to-configure

#vagrant snapshot restore --no-provision ready-to-configure
vagrant provision os-controller --provision-with configure
vagrant provision os-network --provision-with configure
vagrant provision os-compute --provision-with configure
vagrant snapshot save ready-to-verify

# vagrant snapshot restore --no-provision ready-to-verify
# ifconfig enp0s10 up
```
