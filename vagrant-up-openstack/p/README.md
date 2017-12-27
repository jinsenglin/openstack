# Goal

OpenStack + Kubernetes with Kuryr

---

# Usage

```
git clone -b 1.0.0 https://github.com/jinsenglin/k8s.git
cd k8s/with-openstack/vagrant
vagrant up --provision-with download os-controller
vagrant up --provision-with download os-network
vagrant up --provision-with download os-compute
vagrant up --provision-with download k8s-master

vagrant ssh os-controller -c "sudo /vagrant/bootstrap-os-controller.sh configure"
vagrant ssh os-network -c "sudo /vagrant/bootstrap-os-network.sh configure"
vagrant ssh os-compute -c "sudo /vagrant/bootstrap-os-compute.sh configure"
vagrant ssh k8s-master -c "sudo /vagrant/bootstrap-k8s-master.sh configure"

vagrant ssh k8s-master

# FOLLOW the steps described in the file /vagrant/run-e2e-tests.sh with root privilege
```

---

# Note on OpenStack

OpenStack version used is this deployment is ocata.

* type_drivers: flat,vlan,vxlan
* provider network type: flat
* tenant_network_types: vxlan
* mechanism_drivers: openvswitch,l2population
* Kuryr: 0.1.0

---

# Note on Kubernetes

Kubernetes version used is this deployment is 1.4.6.

* Docker: 1.12
* etcd: v3.0.8

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

# Usage 1

```
vagrant up --provision-with bootstrap os-controller
vagrant up --provision-with bootstrap os-network
vagrant up --provision-with bootstrap os-compute
vagrant up --provision-with bootstrap odl-controller
vagrant up --provision-with bootstrap k8s-master

```

# Usage 2

```
vagrant up --provision-with download os-controller
vagrant up --provision-with download os-network
vagrant up --provision-with download os-compute
vagrant up --provision-with download odl-controller
vagrant up --provision-with download k8s-master
vagrant snapshot save ready-to-configure

#vagrant snapshot restore --no-provision ready-to-configure
vagrant provision os-controller --provision-with configure
vagrant provision os-network --provision-with configure
vagrant provision os-compute --provision-with configure
vagrant provision odl-controller --provision-with configure
vagrant provision k8s-master --provision-with configure
vagrant snapshot save ready-to-verify

# vagrant snapshot restore --no-provision ready-to-verify
# ifconfig enp0s10 up
```
