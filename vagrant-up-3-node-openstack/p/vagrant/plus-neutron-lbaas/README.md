REF https://docs.openstack.org/ocata/networking-guide/config-lbaas.html

REF https://kairen.gitbooks.io/openstack-ubuntu/content/deployments/ubuntu/neutron/lbaas.html

Update os-controller

```
# Install package
apt-get install -y python-neutron-lbaas

# Edit the /etc/neutron/neutron.conf file, [DEFAULT] section
crudini --set /etc/neutron/neutron.conf DEFAULT service_plugins $(crudini --get /etc/neutron/neutron.conf DEFAULT service_plugins),neutron_lbaas.services.loadbalancer.plugin.LoadBalancerPluginv2

# Edit the /etc/neutron/neutron_lbaas.conf file, [service_providers] section
crudini --set /etc/neutron/neutron_lbaas.conf service_providers service_provider LOADBALANCERV2:Haproxy:neutron_lbaas.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default

# Run the neutron-lbaas database migration
neutron-db-manage --subproject neutron-lbaas upgrade head

# Restart the neutron-server service
service neutron-server restart
```

Update os-network

```
# Install package
apt-get install -y neutron-lbaasv2-agent

# Edit the /etc/neutron/lbaas_agent.ini file, [DEFAULT] section
crudini --set /etc/neutron/lbaas_agent.ini DEFAULT interface_driver openvswitch

# Edit the /etc/neutron/neutron_lbaas.conf file, [service_providers] section
crudini --set /etc/neutron/neutron_lbaas.conf service_providers service_provider LOADBALANCERV2:Haproxy:neutron_lbaas.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default

# Start the LBaaS v2 agent
service neutron-lbaasv2-agent start
```

Verify

```
neutron lbaas-loadbalancer-create --name test-lb private-subnet
neutron lbaas-loadbalancer-list # provisioning_status ACTIVE

neutron lbaas-listener-create --name test-lb-http --loadbalancer test-lb --protocol HTTP --protocol-port 80

neutron lbaas-pool-create --name test-lb-pool-http --lb-algorithm ROUND_ROBIN --listener test-lb-http --protocol HTTP

neutron lbaas-member-create --subnet private-subnet --address $vm1 --protocol-port 80 test-lb-pool-http
neutron lbaas-member-create --subnet private-subnet --address $vm2 --protocol-port 80 test-lb-pool-http
```
