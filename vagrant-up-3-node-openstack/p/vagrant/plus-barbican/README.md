# Plus

Update os-controller

```
vagrant ssh os-controller -c "sudo /vagrant/update-os-controller.sh plus-barbican" 
```

Verify key manager service

```
openstack secret store --name mysecret --payload j4=]d21

openstack secret get http://os-controller:9311/v1/secrets/655d7d30-c11a-49d9-a0f1-34cdf53a36fa

openstack secret get http://os-controller:9311/v1/secrets/655d7d30-c11a-49d9-a0f1-34cdf53a36fa --payload
```
