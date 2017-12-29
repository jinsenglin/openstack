# Status

Failed to restart openstack-barbican-api.service: Unit openstack-barbican-api.service not found.

# Plus

Update os-controller

```
vagrant ssh os-controller -c "sudo /vagrant/update-os-controller.sh plus-barbican" 
```

Verify key manager service

```
openstack secret store --name mysecret --payload j4=]d21

openstack secret get http://10.0.2.15:9311/v1/secrets/655d7d30-c11a-49d9-a0f1-34cdf53a36fa

openstack secret get http://10.0.2.15:9311/v1/secrets/655d7d30-c11a-49d9-a0f1-34cdf53a36fa --payload
```

REF https://docs.openstack.org/barbican/latest/install/install-ubuntu.html
