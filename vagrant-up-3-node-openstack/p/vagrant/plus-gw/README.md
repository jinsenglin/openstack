# Usage

```
vagrant up --provision-with download gw
vagrant up --provision-with download gw-client

vagrant ssh gw -c "sudo /vagrant/bootstrap-gw.sh configure"
vagrant ssh gw-client -c "sudo /vagrant/bootstrap-gw-client.sh configure"

vagrant ssh gw-client -c "sudo /vagrant/run-e2e-tests.sh"
```

# Plus

In run-e2e-tests.sh, AS-IS `FLAT_NETWORK_GW=10.0.3.1`, TO-BE `FLAT_NETWORK_GW=10.0.3.41`

Create provider network which uses this gateway

```
openstack subnet create --network $PROVIDER_NETWORK_NAME --allocation-pool start=10.0.3.230,end=10.0.3.250 --dns-nameserver 8.8.8.8 --gateway $FLAT_NETWORK_GW --subnet-range 10.0.3.0/24 --no-dhcp $PROVIDER_NETWORK_NAME
```

Ping provider network gateway from vm

```
sshpass -p "cubswin:)" ssh -o StrictHostKeyChecking=no cirros@$SELFSERVICE_INSTANCE_FLOATING_IP ping -c 1 $FLAT_NETWORK_GW
```

Ping 8.8.8.8 from vm

```
sshpass -p "cubswin:)" ssh -o StrictHostKeyChecking=no cirros@$SELFSERVICE_INSTANCE_FLOATING_IP ping -c 1 8.8.8.8
```
