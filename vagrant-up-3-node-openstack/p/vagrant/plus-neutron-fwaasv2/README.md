# Status

FAILED

```
The resource could not be found.
Neutron server returns request_ids: ['req-879b4ec9-44c9-4675-8a07-5585a92c54b4']

2018-01-05 09:17:32.272 19484 WARNING neutron.pecan_wsgi.controllers.root [req-879b4ec9-44c9-4675-8a07-5585a92c54b4 30bb9c3602f24f0fadf754f107f0813b e6efac67cc30405c8defce6154b5f6c6 - default default] No controller found for: fw - returning response code 404: PecanNotFound
2018-01-05 09:17:32.278 19484 INFO neutron.pecan_wsgi.hooks.translation [req-879b4ec9-44c9-4675-8a07-5585a92c54b4 30bb9c3602f24f0fadf754f107f0813b e6efac67cc30405c8defce6154b5f6c6 - default default] POST failed (client error): The resource could not be found.
2018-01-05 09:17:32.287 19484 INFO neutron.wsgi [req-879b4ec9-44c9-4675-8a07-5585a92c54b4 30bb9c3602f24f0fadf754f107f0813b e6efac67cc30405c8defce6154b5f6c6 - default default] 127.0.0.1 "POST /v2.0/fw/firewall_rules HTTP/1.1" status: 404  len: 309 time: 0.9432240
```

# Plus

Update os-controller

```
vagrant ssh os-controller -c "sudo /vagrant/update-os-controller.sh plus-neutron-fwaasv2"
```

Update os-network

```
vagrant ssh os-network -c "sudo /vagrant/update-os-network.sh plus-neutron-fwaasv2"
```

Verify fwaas service

```
neutron firewall-rule-create --name fw-policy1 --protocol tcp --destination-port 22 --action deny

neutron firewall-policy-create --firewall-rules fw-rule1 fw-policy1

neutron firewall-create FIREWALL_POLICY_UUID
```

REF https://docs.openstack.org/ocata/networking-guide/fwaas-v2-scenario.html
