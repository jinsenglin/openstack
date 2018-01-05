# Plus

Update os-controller

```
vagrant ssh os-controller -c "sudo /vagrant/update-os-controller.sh plus-neutron-fwaasv1"
```

Update os-network

```
vagrant ssh os-network -c "sudo /vagrant/update-os-network.sh plus-neutron-fwaasv1"
```

Verify fwaas service

```
neutron firewall-rule-create --name fw-rule1 --protocol tcp --destination-port 22 --action deny

neutron firewall-policy-create --firewall-rules fw-rule1 fw-policy1

neutron firewall-create --name fw1 fw-policy1

neutron firewall-update --router $ROUTER_NAME fw1
```

REF https://docs.openstack.org/ocata/networking-guide/fwaas-v1-scenario.html

REF https://docs.hpcloud.com/hos-1.0/helion/networking/fwaas.html
