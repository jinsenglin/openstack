# Plus

Update os-controller

```
vagrant ssh os-controller -c "sudo /vagrant/update-os-controller.sh plus-neutron-lbaasv2-haproxy"
```

Update os-network

```
vagrant ssh os-network -c "sudo /vagrant/update-os-network.sh plus-neutron-lbaasv2-haproxy"
```

Verify lbaas service

```
neutron lbaas-loadbalancer-create --name test-lb $SELFSERVICE_NETWORK_NAME
neutron lbaas-loadbalancer-list # provisioning_status ACTIVE

neutron lbaas-listener-create --name test-lb-ssh --loadbalancer test-lb --protocol TCP --protocol-port 22

neutron lbaas-pool-create --name test-lb-pool-ssh --lb-algorithm ROUND_ROBIN --listener test-lb-ssh --protocol TCP

neutron lbaas-member-create --subnet $SELFSERVICE_NETWORK_NAME --address $SELFSERVICE_INSTANCE_1_PRIVATE_IP --protocol-port 22 test-lb-pool-ssh # TODO
neutron lbaas-member-create --subnet $SELFSERVICE_NETWORK_NAME --address $SELFSERVICE_INSTANCE_2_PRIVATE_IP --protocol-port 22 test-lb-pool-ssh

neutron lbaas-healthmonitor-create --delay 5 --max-retries 2 --timeout 10 --type TCP --pool test-lb-pool-ssh

openstack floating ip create --port d0eb5111-2ad9-4d17-acfe-7ee4439bc83c $PROVIDER_NETWORK_NAME # NOTE d0eb5111-2ad9-4d17-acfe-7ee4439bc83c is the port id of the load balancer
ping 10.0.3.231 # NOTE 10.0.3.231 is the returend floating ip

sshpass -p "cubswin:)" ssh -o StrictHostKeyChecking=no cirros@10.0.3.231 hostname # selfservice-instance
ssh-keygen -f "/root/.ssh/known_hosts" -R 10.0.3.231
sshpass -p "cubswin:)" ssh -o StrictHostKeyChecking=no cirros@10.0.3.231 hostname # selfservice-instance-2
```
