# Usage

```
vagrant up --provision-with download gw
vagrant up --provision-with download gw-client

vagrant ssh os-gw -c "sudo /vagrant/bootstrap-gw.sh configure"
vagrant ssh os-gw-client -c "sudo /vagrant/bootstrap-gw-client.sh configure"

vagrant ssh os-gw-client -c "sudo /vagrant/run-e2e-tests.sh"
```

# Provider Network Gateway

```
openstack subnet create --network $PROVIDER_NETWORK_NAME --allocation-pool start=10.0.3.230,end=10.0.3.250 --dns-nameserver 8.8.8.8 --gateway 10.0.3.41 --subnet-range 10.0.3.0/24 --no-dhcp $PROVIDER_NETWORK_NAME
```
